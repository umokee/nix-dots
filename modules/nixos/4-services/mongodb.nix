{ config, pkgs, lib, ... }:

let
  mongoNetwork = "mongo-net";
in
{
  services.docker = {
    enable = true;
  };

  systemd.services.mongo-docker = {
    description = "MongoDB + Mongo GUI Docker";
    wants = [ "docker.service" ];
    after = [ "network.target" "docker.service" ];
    serviceConfig = {
      ExecStartPre = ''
        docker network inspect ${mongoNetwork} >/dev/null 2>&1 || docker network create ${mongoNetwork}
      '';

      ExecStart = ''
        docker run -d --rm --name mongodb --network ${mongoNetwork} -p 27017:27017 mongo:latest
        docker run -d --rm --name mongo-gui --network ${mongoNetwork} -p 8080:8080 -e MONGO_URL=mongodb://mongodb:27017 openkbs/mongo-gui-docker:latest
      '';

      ExecStop = ''
        docker stop mongo-gui mongodb
      '';

      Restart = "always";
      RestartSec = "10";
      TimeoutStopSec = "60";
      KillMode = "process";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
