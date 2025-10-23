{ lib, conf }:
let
  waylandCompositors = [
    "hyprland"
    "niri"
    "dwl"
    "sway"
    "river"
    "wayfire"
    "labwc"
    "gnome"
    "plasma6"
    "cagebreak"
  ];
  x11WMs = [
    "i3"
    "bspwm"
    "awesome"
    "xmonad"
    "dwm"
    "openbox"
    "plasma5"
    "xfce"
    "mate"
  ];
  wlrCompositors = [
    "sway"
    "river"
    "dwl"
    "mangowc"
    "cagebreak"
    "labwc"
    "wayfire"
  ];

  hasIn =
    category: feature:
    let
      categoryList = conf.${category}.enable or [ ];
      checkList = features: lib.any (f: lib.elem f categoryList) features;
      checkSingle = f: lib.elem f categoryList;
    in
    lib.isList categoryList && (if lib.isList feature then checkList feature else checkSingle feature);
in
{
  isLaptop = conf.machineType == "laptop";
  isDesktop = conf.machineType == "desktop";
  isServer = conf.machineType == "server";

  isWayland = hasIn "workspace" waylandCompositors;
  isX11 = hasIn "workspace" x11WMs;
  isWM = hasIn "workspace" (waylandCompositors ++ x11WMs);

  isHyprland = hasIn "workspace" "hyprland";
  isKDE = hasIn "workspace" [
    "plasma6"
    "plasma5"
  ];
  isGnome = hasIn "workspace" "gnome";
  isWlr = hasIn "workspace" wlrCompositors;
  isNiri = hasIn "workspace" "niri";
  isDwl = hasIn "workspace" "dwl";
  isMango = hasIn "workspace" "mangowc";

  needsHyprlandPortal = hasIn "workspace" "hyprland";
  needsWlrPortal = hasIn "workspace" wlrCompositors;
  needsKDEPortal = hasIn "workspace" [
    "plasma6"
    "plasma5"
  ];
  needsGnomePortal = hasIn "workspace" [
    "gnome"
    "niri"
  ];
  needsNiriPortal = hasIn "workspace" "niri";

  hasNvidia = hasIn "hardware" "nvidia";
  hasIntel = hasIn "hardware" "intel";
  hasAMD = hasIn "hardware" "amd";

  inherit hasIn;
}
