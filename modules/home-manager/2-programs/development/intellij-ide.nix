{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      #jetbrains.rider
    ];
  };
}
