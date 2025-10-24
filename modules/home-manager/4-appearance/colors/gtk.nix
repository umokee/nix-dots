{
  config,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "workspace" "themes";
  colors = config.colorScheme.palette;
in
{
  config = lib.mkIf enable {
    gtk = {
      gtk2.extraConfig = ''
        gtk-color-scheme = "bg_color:#${colors.base01}\nfg_color:#${colors.base05}\nselected_bg_color:#${colors.base0D}\nselected_fg_color:#${colors.base00}"
      '';
    };

    xdg.configFile."gtk-3.0/gtk.css".text = ''
      @define-color accent_color #${colors.base0D};
      @define-color accent_fg_color #${colors.base00};
      @define-color accent_bg_color #${colors.base0D};
      @define-color window_bg_color #${colors.base01};
      @define-color window_fg_color #${colors.base05};
      @define-color headerbar_bg_color #${colors.base01};
      @define-color headerbar_fg_color #${colors.base05};
      @define-color popover_bg_color #${colors.base01};
      @define-color popover_fg_color #${colors.base05};
      @define-color view_bg_color #${colors.base00};
      @define-color view_fg_color #${colors.base05};
      @define-color card_bg_color #${colors.base00};
      @define-color card_fg_color #${colors.base05};
      @define-color sidebar_bg_color #${colors.base01};
      @define-color sidebar_fg_color #${colors.base05};
      @define-color sidebar_border_color #${colors.base01};
      @define-color sidebar_backdrop_color #${colors.base01};

      @define-color destructive_bg_color #${colors.base08};
      @define-color destructive_fg_color #${colors.base00};
      @define-color success_bg_color #${colors.base0B};
      @define-color success_fg_color #${colors.base00};
      @define-color warning_bg_color #${colors.base0A};
      @define-color warning_fg_color #${colors.base00};
    '';

    xdg.configFile."gtk-4.0/gtk.css".text = ''
      @define-color accent_color #${colors.base0D};
      @define-color accent_fg_color #${colors.base00};
      @define-color accent_bg_color #${colors.base0D};
      @define-color window_bg_color #${colors.base01};
      @define-color window_fg_color #${colors.base05};
      @define-color headerbar_bg_color #${colors.base01};
      @define-color headerbar_fg_color #${colors.base05};
      @define-color popover_bg_color #${colors.base01};
      @define-color popover_fg_color #${colors.base05};
      @define-color view_bg_color #${colors.base00};
      @define-color view_fg_color #${colors.base05};
      @define-color card_bg_color #${colors.base00};
      @define-color card_fg_color #${colors.base05};
      @define-color sidebar_bg_color #${colors.base01};
      @define-color sidebar_fg_color #${colors.base05};
      @define-color sidebar_border_color #${colors.base01};
      @define-color sidebar_backdrop_color #${colors.base01};

      @define-color destructive_bg_color #${colors.base08};
      @define-color destructive_fg_color #${colors.base00};
      @define-color success_bg_color #${colors.base0B};
      @define-color success_fg_color #${colors.base00};
      @define-color warning_bg_color #${colors.base0A};
      @define-color warning_fg_color #${colors.base00};
    '';
  };
}
