{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "workspace" "mangowc";
  monitorTags = {
    "DP-3" = {
      "1" = "tile";
      "2" = "tile";
      "3" = "tile";
      "4" = "tile";
      "5" = "tile";
      "6" = "tile";
      "7" = "tile";
      "8" = "tile";
      "9" = "tile";
    };
    "DP-4" = {
      "1" = "scroller";
      "2" = "scroller";
      "3" = "scroller";
      "4" = "scroller";
      "5" = "scroller";
      "6" = "vscroller";
      "7" = "scroller";
      "8" = "scroller";
      "9" = "scroller";
    };
    "HDMI-A-5" = {
      "1" = "tile";
      "2" = "tile";
      "3" = "tile";
      "4" = "tile";
      "5" = "tile";
      "6" = "tile";
      "7" = "tile";
      "8" = "tile";
      "9" = "tile";
    };
  };

  generateTagRules = lib.concatStringsSep "\n" (
    lib.flatten (
      lib.mapAttrsToList (
        monitor: tags:
        lib.mapAttrsToList (
          id: layout: "tagrule=id:${id},monitor_name:${monitor},layout_name:${layout}"
        ) tags
      ) monitorTags
    )
  );
in
{
  config = lib.mkIf enable {
    home.file.".config/mango/rules.conf".text = ''
      # Tag rules
      ${generateTagRules}

      # Window rules
      windowrule=focused_opacity:0.95,unfocused_opacity:0.95
      windowrule=focused_opacity:1.0,unfocused_opacity:1.0,noblur:1,appid:foot|equibop|org\.quickshell|imv|swappy

      # Float rules
      windowrule=isfloating:1,no_force_center:0,appid:guifetch
      windowrule=isfloating:1,no_force_center:0,appid:yad
      windowrule=isfloating:1,no_force_center:0,appid:zenity
      windowrule=isfloating:1,no_force_center:0,appid:wev
      windowrule=isfloating:1,no_force_center:0,appid:org\.gnome\.FileRoller
      windowrule=isfloating:1,no_force_center:0,appid:file-roller
      windowrule=isfloating:1,no_force_center:0,appid:blueman-manager
      windowrule=isfloating:1,no_force_center:0,appid:com\.github\.GradienceTeam\.Gradience
      windowrule=isfloating:1,no_force_center:0,appid:feh
      windowrule=isfloating:1,no_force_center:0,appid:imv
      windowrule=isfloating:1,no_force_center:0,appid:system-config-printer
      windowrule=isfloating:1,no_force_center:0,appid:org\.quickshell

      # Float + size rules
      windowrule=isfloating:1,width:800,height:600,no_force_center:0,appid:foot,title:nmtui
      windowrule=isfloating:1,width:1000,height:800,no_force_center:0,appid:org\.gnome\.Settings
      windowrule=isfloating:1,width:900,height:700,no_force_center:0,appid:org\.pulseaudio\.pavucontrol|yad-icon-browser
      windowrule=isfloating:1,width:800,height:600,no_force_center:0,appid:nwg-look

      # Title-based float rules
      windowrule=isfloating:1,no_force_center:0,title:(Select|Open)( a)? (File|Folder)(s)?
      windowrule=isfloating:1,no_force_center:0,title:File (Operation|Upload)( Progress)?
      windowrule=isfloating:1,no_force_center:0,title:.* Properties
      windowrule=isfloating:1,no_force_center:0,title:Export Image as PNG
      windowrule=isfloating:1,no_force_center:0,title:GIMP Crash Debug
      windowrule=isfloating:1,no_force_center:0,title:Save As
      windowrule=isfloating:1,no_force_center:0,title:Library

      # Picture-in-Picture
      windowrule=isfloating:1,offsetx:45,offsety:45,width:400,height:300,isoverlay:1,title:Picture(-| )in(-| )[Pp]icture

      # Steam rules
      windowrule=isfloating:1,no_force_center:0,title:(Friends List|Steam Settings),appid:steam
      windowrule=appid:steam_app_[0-9]+

      # ATLauncher
      windowrule=isfloating:1,no_force_center:0,appid:com-atlauncher-App,title:ATLauncher Console

      # Fusion360
      windowrule=noblur:1,title:Fusion360|(Marking Menu),appid:fusion360\.exe
    '';
  };
}
