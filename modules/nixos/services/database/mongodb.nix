{ pkgs, ... }:

let
  projectPath = "/var/lib/mongo-gui";
  composeFile = "${projectPath}/docker-compose.yml";
  composeContent = ''
    version: "3.9"
    services:
      mongodb:
        image: mongo:latest
        container_name: mongodb
        ports:
          - "27017:27017"
        volumes:
          - mongo_data:/data/db
        restart: unless-stopped

      mongo-express:
        image: mongo-express:latest
        container_name: mongo-express
        ports:
          - "8081:8081"
        environment:
          ME_CONFIG_MONGODB_SERVER: mongodb
          ME_CONFIG_MONGODB_PORT: 27017
        depends_on:
          - mongodb
        restart: unless-stopped

    volumes:
      mongo_data:
  '';
in
{
  environment.systemPackages = with pkgs; [
    gtk3
    libx11
  ];

  virtualisation.docker.enable = true;

  systemd.tmpfiles.rules = [
    "d ${projectPath} 0755 root root -"
  ];

  system.activationScripts.mongoGuiComposeConfig = ''
    mkdir -p ${projectPath}
    echo '${composeContent}' > ${composeFile}
    chown root:root ${composeFile}
    chmod 644 ${composeFile}
  '';

  systemd.services.mongo-gui-app = {
    description = "MongoDB + Mongo GUI Compose";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.docker
      pkgs.docker-compose
    ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = projectPath;
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      Restart = "always";
      RestartSec = "10s";
    };
    preStart = ''
      cd ${projectPath}
      ${pkgs.docker-compose}/bin/docker-compose down 2>/dev/null || true
    '';
  };
}
