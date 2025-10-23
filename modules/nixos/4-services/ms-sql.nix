{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "ms-sql";
in
{
  config = lib.mkIf enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    systemd.tmpfiles.rules = [
      "d /var/lib/mssql 0755 10001 10001 -"
    ];

    virtualisation.oci-containers.containers.mssql = {
      image = "mcr.microsoft.com/mssql/server:2022-latest";

      environment = {
        ACCEPT_EULA = "Y";
        MSSQL_SA_PASSWORD = "Password!11!";
        MSSQL_PID = "Developer";
      };

      ports = [ "1433:1433" ];
      volumes = [ "/var/lib/mssql:/var/opt/mssql" ];
      extraOptions = [ "--hostname=mssql-server" ];
    };

    environment.systemPackages = with pkgs; [
      sqlcmd
    ];
  };
}
