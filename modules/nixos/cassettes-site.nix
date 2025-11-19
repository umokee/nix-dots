{
  config,
  pkgs,
  lib,
  conf,
  helpers,
  ...
}:

let
  enable = helpers.hasIn "services" "cassette-site";

  cassetteRepo = pkgs.fetchFromGitHub {
    owner = "umokee";
    repo = "cassettes-site";
    rev = "main";
    sha256 = "sha256-Rt34UdnrYU5/kVak7PsNRq3BBY+A+DEPJtoFrrQI8Os=";
  };

  projectPath = "/var/lib/cassette-site";
  jwtSecretFile = "/var/lib/cassette-secrets/jwt-secret";
in
{
  config = lib.mkIf enable {
    virtualisation.docker.enable = true;
    users.users."${conf.username}".extraGroups = [ "docker" ];

    networking.firewall.allowedTCPPorts = [
      80
      8443
    ];

    systemd.tmpfiles.rules = [
      "d ${projectPath} 0755 root root -"
      "d /var/lib/cassette-secrets 0700 root root -"
    ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."umkcloud.ru" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 8443;
            ssl = true;
          }
          {
            addr = "0.0.0.0";
            port = 80;
            ssl = false;
          }
        ];
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://localhost:80";
          proxyWebsockets = true;
        };

        locations."/api/" = {
          proxyPass = "http://localhost:5000/";
          proxyWebsockets = true;
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "hituaev@gmail.com";
    };

    systemd.services.cassette-app = {
      description = "Cassette Docker Compose from Git";
      after = [
        "docker.service"
        "docker.socket"
      ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [
        pkgs.docker
        pkgs.docker-compose
        pkgs.rsync
        pkgs.openssl
      ];

      preStart = ''
        ${pkgs.rsync}/bin/rsync -a --delete ${cassetteRepo}/ ${projectPath}/
        chmod -R u+w ${projectPath}

        if [ ! -f ${jwtSecretFile} ]; then
          echo "JWT_SECRET=$(${pkgs.openssl}/bin/openssl rand -base64 32)" > ${jwtSecretFile}
          chmod 600 ${jwtSecretFile}
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = projectPath;
        EnvironmentFile = jwtSecretFile;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        Restart = "on-failure";
      };
    };
  };
}
