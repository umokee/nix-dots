{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "programs" "appimage";
in
{
  config = lib.mkIf enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
