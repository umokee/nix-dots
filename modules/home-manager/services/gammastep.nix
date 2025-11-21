{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "gammastep";
in
{
  config = lib.mkIf enable {
    services.gammastep = {
      enable = true;
      package = pkgs.gammastep;

      latitude = 43.1155;
      longitude = 131.8855;

      temperature = {
        day = 6000;
        night = 3200;
      };
    };
  };
}
