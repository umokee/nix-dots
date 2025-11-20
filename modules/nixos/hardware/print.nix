{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "hardware" "print";
in
{
  config = lib.mkIf enable (
    let
      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    in
    {
      environment.systemPackages = with pkgs; [
        gutenprint
      ];

      services.printing = {
        enable = true;
        startWhenNeeded = true;
        drivers = with pkgs; [
          #brgenml1cupswrapper
          #brgenml1lpr
          #brlaser
          #cnijfilter2
          #epkowa
          #gutenprintBin unic
          #hplip
          #epson-escpr2
          #epson-escpr
          epson-201401w

          #samsung-unified-linux-driver
          #splix
        ];
      };

      services.avahi = {
        enable = false;
        nssmdns4 = true;
        openFirewall = true;
      };

      services.udev.packages = with pkgs; [
        sane-airscan
        utsushi
      ];

      hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [
          sane-airscan
          epkowa
          utsushi
          epsonscan2
        ];
      };

      programs.system-config-printer.enable = true;

      users.groups.scanner.members = normalUsers;
      users.groups.lp.members = normalUsers;
    }
  );
}
