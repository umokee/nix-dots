{
  pkgs,
  lib,
  conf,
  helpers,
  ...
}:

let
  enable = helpers.hasIn "services" "cassettes-site";
  projectPath = "/var/lib/cassette-site";
  jwtSecretFile = "/var/lib/cassette-secrets/jwt-secret";
in
{
  config = lib.mkIf enable {
    virtualisation.docker.enable = true;
    users.users."${conf.username}".extraGroups = [ "docker" ];

    networking.firewall.allowedTCPPorts = [ 8080 ];

    systemd.tmpfiles.rules = [
      "d ${projectPath} 0755 root root -"
      "d /var/lib/cassette-secrets 0700 root root -"
      "f ${jwtSecretFile} 0600 root root -"
    ];
    
    services.nginx.enable = false;
    services.caddy = {
      enable = true;
      
      virtualHosts.":8080" = {
        extraConfig = ''
          handle /api/* {
            reverse_proxy localhost:5000
          }
          
          handle {
            reverse_proxy localhost:3000
          }
        '';
      };
    };

    systemd.services.cassette-git-sync = {
      description = "Sync Cassette site from Git";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-tmpfiles-setup.service" ];
      requires = [ "systemd-tmpfiles-setup.service" ];
      path = [ pkgs.git pkgs.coreutils pkgs.bash ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -e
        
        mkdir -p ${projectPath}
        chmod 755 ${projectPath}
        
        if [ -d ${projectPath}/.git ]; then
          cd ${projectPath}
          ${pkgs.git}/bin/git fetch origin
          ${pkgs.git}/bin/git reset --hard origin/main
          ${pkgs.git}/bin/git pull origin main
        else
          rm -rf ${projectPath}/*
          rm -rf ${projectPath}/.* 2>/dev/null || true
          cd ${projectPath}
          ${pkgs.git}/bin/git clone https://github.com/umokee/cassettes-site.git .
        fi
        
        chmod -R u+w ${projectPath}
      '';
    };

    systemd.services.cassette-jwt-init = {
      description = "Generate JWT secret for Cassette";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-tmpfiles-setup.service" ];
      requires = [ "systemd-tmpfiles-setup.service" ];
      path = [ pkgs.openssl pkgs.coreutils ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /var/lib/cassette-secrets
        chmod 700 /var/lib/cassette-secrets
        
        if [ ! -s ${jwtSecretFile} ]; then
          echo "JWT_SECRET=$(${pkgs.openssl}/bin/openssl rand -base64 32)" > ${jwtSecretFile}
          chmod 600 ${jwtSecretFile}
        fi
      '';
    };

    systemd.services.cassette-app = {
      description = "Cassette Docker Compose from Git";
      after = [
        "docker.service"
        "docker.socket"
        "cassette-git-sync.service"
        "cassette-jwt-init.service"
        "caddy.service"
      ];
      requires = [
        "docker.service"
        "cassette-git-sync.service"
        "cassette-jwt-init.service"
      ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.docker
        pkgs.docker-compose
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = projectPath;
        EnvironmentFile = jwtSecretFile;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --build";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      };
      preStart = ''
        if [ ! -d ${projectPath} ]; then
          echo "Error: ${projectPath} does not exist"
          exit 1
        fi
        
        if [ ! -d ${projectPath}/.git ]; then
          echo "Error: ${projectPath} is not a git repository"
          exit 1
        fi
        
        cd ${projectPath}
        ${pkgs.docker-compose}/bin/docker-compose down 2>/dev/null || true
      '';
    };
  };
}
