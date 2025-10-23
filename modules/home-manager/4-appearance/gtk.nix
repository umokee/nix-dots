{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  cfg = {
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    font = {
      name = "Inter";
      package = pkgs.inter;
      size = 11;
    };
  };
in
{
  config = lib.mkIf helpers.isWM {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
        "org/gnome/desktop/wm/preferences" = {
          button-layout = ":";
        };
        "org/nemo/preferences" = {
          ignore-view-metadata = true;
        };
        "org/nemo/icon-view" = {
          default-zoom-level = "larger";
        };
        "org/nemo/list-view" = {
          default-zoom-level = "larger";
        };
      };
    };

    gtk = {
      enable = true;

      font = {
        name = cfg.font.name;
        size = cfg.font.size;
        package = cfg.font.package;
      };

      theme = {
        name = cfg.theme.name;
        package = cfg.theme.package;
      };

      gtk3 = {
        extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };
    };

    home.sessionVariables = {
      GTK_THEME = cfg.theme.name;
    };
  };
}
