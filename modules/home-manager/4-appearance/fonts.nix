{
  config,
  pkgs,
  lib,
  helpers,
  ...
}:
{
  home.packages =
    with pkgs;
    lib.mkIf helpers.isWM [
      nerd-fonts.fira-code
      nerd-fonts.hack
      montserrat
      inter
      roboto
      font-awesome
    ];
}
