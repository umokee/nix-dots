{ conf, ... }:
{
  home = {
    username = conf.username;
    homeDirectory = "/home/${conf.username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
