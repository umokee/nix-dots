{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "postgresql";

  postgresConfig = "/home/user/postgresql/pg_config";

  postgresqlConf = ''
    listen_addresses = '*'
    port = 5432
    max_connections = 100
    shared_buffers = 256MB
    effective_cache_size = 1GB
    maintenance_work_mem = 64MB
    checkpoint_completion_target = 0.9
    wal_buffers = 16MB
    work_mem = 4MB
    min_wal_size = 2GB
    max_wal_size = 8GB
    log_min_duration_statement = 1000
    log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
    log_checkpoints = on
    log_connections = on
    log_disconnections = on
    log_lock_waits = on
    data_directory = '/var/lib/postgresql/data'
    wal_level = replica
    max_wal_senders = 3
    max_replication_slots = 3
  '';

  pgHbaConf = ''
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            md5
    host    all             all             ::1/128                 md5
    host    all             all             0.0.0.0/0               md5
  '';

  setupScript = pkgs.writeShellScript "postgres-setup" ''
    set -e
    mkdir -p ${postgresConfig}
    
    if [ ! -f ${postgresConfig}/postgresql.conf ]; then
      cat > ${postgresConfig}/postgresql.conf << 'CONF'
    ${postgresqlConf}
    CONF
    fi
    
    if [ ! -f ${postgresConfig}/pg_hba.conf ]; then
      cat > ${postgresConfig}/pg_hba.conf << 'CONF'
    ${pgHbaConf}
    CONF
    fi
    
    
  '';
in
{
  config = lib.mkIf enable {
    environment.etc."containers/policy.json" = {
      text = builtins.toJSON {
        default = [
          {
            type = "insecureAcceptAnything";
          }
        ];
      };
      mode = "0644";
    };

    systemd.services.postgres-podman = {
      description = "PostgreSQL 16 container via Podman";
      wants = [ "network.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10";
        User = "root";
        Type = "simple";
        TimeoutStopSec = "30";

        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p ${postgresConfig}"
          "${setupScript}"
          "-${pkgs.podman}/bin/podman rm -f postgres"
        ];

        ExecStart = ''
          ${pkgs.podman}/bin/podman run \
            --name postgres \
            --replace \
            -e POSTGRES_PASSWORD=11 \
            -v ${postgresConfig}/postgresql.conf:/etc/postgresql/postgresql.conf:ro \
            -v ${postgresConfig}/pg_hba.conf:/etc/postgresql/pg_hba.conf:ro \
            -p 5432:5432 \
            docker.io/library/postgres:16 \
            -c config_file=/etc/postgresql/postgresql.conf \
            -c hba_file=/etc/postgresql/pg_hba.conf
        '';

        ExecStop = "${pkgs.podman}/bin/podman stop -t 30 postgres";
        ExecStopPost = "-${pkgs.podman}/bin/podman rm -f postgres";
        KillMode = "control-group";
      };

      wantedBy = [ "multi-user.target" ];
    };

    environment.systemPackages = with pkgs; [
      postgresql
      pgadmin4-desktopmode
      podman
    ];

    networking.firewall.allowedTCPPorts = [ 5432 ];
  };
}
