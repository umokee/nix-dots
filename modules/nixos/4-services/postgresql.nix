{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "postgresql";

  postgresData = "/home/user/postgresql/pgdata";
  postgresBackup = "/home/user/postgresql/pg_backup";
  postgresConfig = "/home/user/postgresql/pg_config";
in
{
  config = lib.mkIf enable {
    systemd.services.postgres-podman = {
      description = "PostgreSQL 16 container via Podman";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        User = "root";
        ExecStartPre = ''
          ${pkgs.coreutils}/bin/mkdir -p ${postgresData} ${postgresBackup} ${postgresConfig}
          ${pkgs.coreutils}/bin/mkdir -p ${postgresBackup}/physical ${postgresBackup}/logical ${postgresBackup}/wal
          ${pkgs.coreutils}/bin/chown -R 999:999 ${postgresData} ${postgresBackup} ${postgresConfig}
          ${pkgs.coreutils}/bin/chmod -R 755 ${postgresData} ${postgresBackup} ${postgresConfig}
        '';
        ExecStart = ''
          ${pkgs.podman}/bin/podman run --name postgres \
            -e POSTGRES_PASSWORD=1postgres1 \
            -v ${postgresData}:/var/lib/postgresql/data:z \
            -v ${postgresBackup}:/var/lib/pg_backup:z \
            -v ${postgresConfig}/postgresql.conf:/etc/postgresql/postgresql.conf:z \
            -v ${postgresConfig}/pg_hba.conf:/etc/postgresql/pg_hba.conf:z \
            -p 5432:5432 \
            postgres:16 \
            -c config_file=/etc/postgresql/postgresql.conf \
            -c hba_file=/etc/postgresql/pg_hba.conf
        '';
        ExecStop = "${pkgs.podman}/bin/podman stop postgres";
        ExecStopPost = "${pkgs.podman}/bin/podman rm postgres";
        KillMode = "control-group";
        TimeoutStopSec = "30";
        RestartSec = "10";
      };
      wantedBy = [ "multi-user.target" ];
    };

    environment.systemPackages = with pkgs; [
      postgresql
      pgadmin4-desktopmode
    ];
  };
}
