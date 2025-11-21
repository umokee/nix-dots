{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      #jetbrains.rider
      jetbrains.webstorm
    ];
  };
}
