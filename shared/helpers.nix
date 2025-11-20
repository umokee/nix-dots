{ lib, conf }:
let
  waylandCompositors = [
    "hyprland"
    "niri"
  ];
  x11WMs = [
    "bspwm"
    "dwm"
  ];
  wlrCompositors = [
    "sway"
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
  isWlr = hasIn "workspace" wlrCompositors;
  isNiri = hasIn "workspace" "niri";

  needsHyprlandPortal = hasIn "workspace" "hyprland";
  needsWlrPortal = hasIn "workspace" wlrCompositors;

  hasNvidia = hasIn "hardware" "nvidia";
  hasIntel = hasIn "hardware" "intel";
  hasAMD = hasIn "hardware" "amd";

  inherit hasIn;
}
