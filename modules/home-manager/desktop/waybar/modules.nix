{ ... }:
{
  "hyprland/workspaces" = {
    disable-scroll = true;
    all-outputs = true;
    warp-on-scroll = false;
    format = "{name}";
    persistent-workspaces = {
      "*" = 9;
    };
  };

  "hyprland/window" = {
    max-length = 40;
    separate-outputs = false;
  };

  "ext/workspaces" = {
    format = "{icon}";
    ignore-hidden = false;
    on-click = "activate";
    sort-by-id = true;
  };

  "dwl/tags" = {
    num-tags = 9;
  };

  "dwl/window" = {
    format = "[{layout}]{title}";
  };

  tray = {
    spacing = 10;
  };

  clock = {
    format-alt = "{:%Y-%m-%d}";
  };

  cpu = {
    format = "CPU: {usage}%";
    tooltip = false;
  };

  memory = {
    format = "Mem: {used}GiB";
  };

  disk = {
    interval = 60;
    path = "/";
    format = "Disk: {free}";
  };

  battery = {
    states = {
      good = 95;
      warning = 30;
      critical = 15;
    };
    format = "Bat: {capacity}% {icon} {time}";
    format-plugged = "{capacity}% ";
    format-alt = "Bat {capacity}%";
    format-time = "{H}:{M}";
    format-icons = [
      ""
      ""
      ""
      ""
      ""
    ];
  };

  network = {
    format = "Online";
    format-disconnected = "Disconnected ⚠";
  };

  "custom/sep" = {
    format = "|";
    interval = "once";
    tooltip = false;
  };
}
