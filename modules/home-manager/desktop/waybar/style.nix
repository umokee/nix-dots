{ config, ... }:
let
  palette = config.colorScheme.palette;
in
''
  @define-color bg    #${palette.base00};
  @define-color fg    #${palette.base05};
  @define-color blk   #${palette.base01};
  @define-color red   #${palette.base08};
  @define-color grn   #${palette.base0B};
  @define-color ylw   #${palette.base0A};
  @define-color blu   #${palette.base0D};
  @define-color mag   #${palette.base0E};
  @define-color cyn   #${palette.base0C};
  @define-color brblk #${palette.base02};
  @define-color white #${palette.base06};

  * {
      font-family: "JetBrainsMono Nerd Font", monospace;
      font-size: 16px;
      font-weight: bold;
  }

  window#waybar {
      background-color: @bg;
      color: @fg;
  }

  #workspaces button {
      padding: 0 6px;
      color: @cyn;
      background: transparent;
      border-bottom: 3px solid @bg;
      border-radius: 0;
  }

  #workspaces button.active {
      color: @cyn;
      border-bottom: 3px solid @mag;
  }

  #workspaces button.empty {
      color: @white;
  }

  #workspaces button.empty.active {
      color: @cyn;
      border-bottom: 3px solid @mag;
  }

  #workspaces button.urgent {
      background-color: @red;
  }

  button:hover {
      background: inherit;
      box-shadow: inset 0 -3px @mag;
  }

  #clock,
  #custom-sep,
  #battery,
  #cpu,
  #memory,
  #disk,
  #network,
  #tray {
      padding: 0 8px;
      color: @white;
  }

  #custom-sep {
      color: @brblk;
  }

  #clock {
      color: @cyn;
      border-bottom: 4px solid @cyn;
  }

  #battery {
      color: @mag;
      border-bottom: 4px solid @mag;
  }

  #disk {
      color: @ylw;
      border-bottom: 4px solid @ylw;
  }

  #memory {
      color: @mag;
      border-bottom: 4px solid @mag;
  }

  #cpu {
      color: @grn;
      border-bottom: 4px solid @grn;
  }

  #network {
      color: @blu;
      border-bottom: 4px solid @blu;
  }

  #network.disconnected {
      background-color: @red;
  }

  #tray {
      background-color: @bg;
  }
''
