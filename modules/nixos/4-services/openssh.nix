{
  config,
  lib,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "openssh";

  cfg = {
    authorizedKeys = {
      user = [  ];
    };
  };
in
{
  config = lib.mkIf enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };

    services.openssh = {
      enable = true;
      ports = [ 22 ];

      settings = {
        PermitRootLogin = if helpers.isServer then "prohibit-password" else "yes";
        PasswordAuthentication = if helpers.isServer then false else true;
        KbdInteractiveAuthentication = false;

        X11Forwarding = lib.mkIf helpers.isServer false;
        AllowTcpForwarding = lib.mkIf helpers.isServer "yes";
        AllowAgentForwarding = lib.mkIf helpers.isServer false;

        PubkeyAuthentication = true;
        AuthenticationMethods = if helpers.isServer 
          then "publickey" 
          else "publickey,password";

        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        MaxAuthTries = 3;
        LoginGraceTime = 60;
      };

      extraConfig = lib.mkIf helpers.isServer ''
        AllowUsers user
        Protocol 2
        HostbasedAuthentication no
        IgnoreRhosts yes
        PermitEmptyPasswords no
      '';
    };

    users.users = lib.mapAttrs (user: keys: {
      openssh.authorizedKeys.keys = keys;
    }) cfg.authorizedKeys;
  };
}
