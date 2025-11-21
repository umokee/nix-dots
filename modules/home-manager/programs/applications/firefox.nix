{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    pkgs.cascadia-code
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      userChrome = builtins.concatStringsSep "\n" [
        (builtins.readFile "${inputs.minimalFox}/userChrome.css")
        ''
          #nav-bar {
            top: 0 !important;
            margin-top: 8px !important;
          }
        ''
      ];

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;

        "font.name.monospace.x-western" = "Cascadia Code";
        "font.name.sans-serif.x-western" = "Cascadia Code";
        "font.name.serif.x-western" = "Cascadia Code";
        "font.size.monospace.x-western" = 12;

        "browser.tabs.tabmanager.enabled" = false;
        "browser.tabs.hoverPreview" = false;
      };
    };
  };
}
