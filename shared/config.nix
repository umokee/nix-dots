{ lib, hostname }:
let
  machineType = hostname;

  commonVars = {
    hostname = "nixos";
    inherit machineType;

    username = "user";

    colorScheme = "dark";
    wallpaperName = "backyard";

    default = {
      terminal = "foot";
      editor = "code";
      visual = "code";
      browser = "zen";
    };
  };

  desktopVars = lib.recursiveUpdate commonVars {
    base = {
      enable = [
        "boot"
        "system"
        "security"
        "locale"
        "network"
        "users"
        "fonts"
      ];
    };
    hardware = {
      enable = [
        "sound"
        "keyboard-mouse"
        "intel"
        "nvidia"
        "power"
        "print"
      ];
    };
    workspace = {
      enable = [
        "hyprland"
        #"wallpapers"
        "screenshots"
        "themes"
      ];
    };
    programs = {
      enable = [
        "appimage"
        "nix-lang"
        "python-lang"
        "dotnet"
        "nodejs"
        "gaming"
      ];
    };
    services = {
      enable = [
        "openssh"
        "gammastep"
        "virtual-machine"
        "print"
      ];
    };
  };

  laptopVars = lib.recursiveUpdate commonVars {
    base = {
      enable = [
        "boot"
        "system"
        "security"
        "locale"
        "network"
        "users"
        "fonts"
      ];
    };
    hardware = {
      enable = [
        "keyboard-mouse"
        "amd"
        "power"
      ];
    };
    workspace = {
      enable = [
        "dwl"
        "wallpapers"
        "themes"
      ];
    };
    programs = {
      enable = [
        "nix-lang"
        "python-lang"
        "dotnet"
        "nodejs"
      ];
    };
    services = {
      enable = [
        "openssh"
        "sing-box"
        "brightnessctl"
      ];
    };
  };

  serverVars = lib.recursiveUpdate commonVars {
    base = {
      enable = [
        "boot"
        "system"
        "security"
        "locale"
        "network"
        "users"
      ];
    };
    hardware = {
      enable = [ ];
    };
    workspace = {
      enable = [ ];
    };
    programs = {
      enable = [ ];
    };
    services = {
      enable = [
        "openssh"
        "xray"
        "traefik"
        "fail2ban"
      ];
    };
  };
in
if machineType == "laptop" then
  laptopVars
else if machineType == "server" then
  serverVars
else if machineType == "desktop" then
  desktopVars
else
  throw "Unknown hostname: ${hostname}. Expected: desktop, laptop, or server"
