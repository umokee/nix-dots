{
  lib,
  pkgs,
  helpers,
  ...
}:
{
  config = lib.mkIf helpers.isWM {
    home.packages = with pkgs; [
      xdg-utils
    ];

    xdg = {
      enable = true;

      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "zen.desktop";
          "x-scheme-handler/http" = "zen.desktop";
          "x-scheme-handler/https" = "zen.desktop";
          "x-scheme-handler/unknown" = "zen.desktop";

          "image/jpeg" = "qimgv.desktop";
          "image/png" = "qimgv.desktop";
          "image/gif" = "qimgv.desktop";
          "image/webp" = "qimgv.desktop";
          "image/bmp" = "qimgv.desktop";
          "image/icon" = "qimgv.desktop";

          "video/webm" = "qimgv.desktop";
          "video/mp4" = "qimgv.desktop";
          "video/x-matroska" = "qimgv.desktop";
          "video/avi" = "qimgv.desktop";

          "audio/webm" = "qimgv.desktop";
          "audio/wav" = "qimgv.desktop";
          "audio/ogg" = "qimgv.desktop";
          "audio/opus" = "qimgv.desktop";
          "audio/flac" = "qimgv.desktop";
          "audio/mp4" = "qimgv.desktop";
          "audio/mpeg" = "qimgv.desktop";
          "audio/mp3" = "qimgv.desktop";

          "text/plain" = "code.desktop";
          "text/markdown" = "code.desktop";

          "text/x-csrc" = "code.desktop";
          "text/x-chdr" = "code.desktop";
          "text/x-c++src" = "code.desktop";
          "text/x-c++hdr" = "code.desktop";
          "text/x-python" = "code.desktop";
          "text/x-script.python" = "code.desktop";
          "text/x-rust" = "code.desktop";
          "text/x-java" = "code.desktop";
          "text/x-go" = "code.desktop";
          "text/javascript" = "code.desktop";
          "application/javascript" = "code.desktop";
          "application/x-javascript" = "code.desktop";
          "text/x-javascript" = "code.desktop";
          "application/json" = "code.desktop";
          "application/xml" = "code.desktop";
          "text/xml" = "code.desktop";
          "text/x-shellscript" = "code.desktop";
          "application/x-shellscript" = "code.desktop";
          "text/x-sh" = "code.desktop";

          "application/zip" = "xarchiver.desktop";
          "application/x-7z-compressed" = "xarchiver.desktop";
          "application/x-rar" = "xarchiver.desktop";
          "application/x-tar" = "xarchiver.desktop";
          "application/gzip" = "xarchiver.desktop";
        };
      };

      userDirs = {
        enable = true;
        createDirectories = true;
      };

      portal = {
        enable = true;
        xdgOpenUsePortal = true;

        extraPortals =
          with pkgs;
          [
            xdg-desktop-portal-gtk
          ]
          ++ lib.optionals helpers.isWlr [
            xdg-desktop-portal-wlr
          ]
          ++ lib.optionals helpers.isHyprland [
            xdg-desktop-portal-hyprland
          ];

        config = {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Settings" = "gtk";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.Inhibit" = "gtk";
          };
          mangowc = {
            default = [
              "wlr"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
            "org.freedesktop.impl.portal.Settings" = "gtk";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.Inhibit" = "gtk";
          };
          common = {
            default = [ "gtk" ];
          };
        };
      };
    };
  };
}
