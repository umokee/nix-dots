{ lib, conf }:
let
  waylandCompositors = [
    "hyprland"
    "niri"
    "dwl"
    "mangowc"
  ];
  x11WMs = [
    "bspwm"
    "dwm"
  ];
  wlrCompositors = [
    "sway"
    "dwl"
    "mangowc"
  ];

  hasIn =
    category: feature:
    let
      categoryList = conf.${category}.enable or [ ];
    in
    if lib.isList feature then
      lib.any (f: lib.elem f categoryList) feature
    else
      lib.elem feature categoryList;
in
{
  isLaptop = conf.machineType == "laptop";
  isDesktop = conf.machineType == "desktop";
  isServer = conf.machineType == "server";

  isWayland = hasIn "workspace" waylandCompositors;
  isX11 = hasIn "workspace" x11WMs;
  isWM = hasIn "workspace" (waylandCompositors ++ x11WMs);

  isHyprland = hasIn "workspace" "hyprland";
  isWlr = hasIn "workspace" wlrCompositors;
  isNiri = hasIn "workspace" "niri";
  isDwl = hasIn "workspace" "dwl";
  isMango = hasIn "workspace" "mangowc";

  needsHyprlandPortal = hasIn "workspace" "hyprland";
  needsWlrPortal = hasIn "workspace" wlrCompositors;

  hasNvidia = hasIn "hardware" "nvidia";
  hasIntel = hasIn "hardware" "intel";
  hasAMD = hasIn "hardware" "amd";

  inherit hasIn;
}
