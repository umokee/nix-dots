{
  pkgs,
  lib,
  helpers,
  inputs,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      qimgv
      czkawka-full
      mullvad-browser
      tor-browser
      telegram-desktop
      libreoffice-fresh
      xlsclients
      xarchiver
      transmission_4-gtk
      nemo
      xmind
      (termius.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ sqlite ];
      }))
      vial
      drawio
      discord
      claude-code
      brave
      wev
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
      insomnia
      kooha
      #jetbrains.rider
    ]
    ++ lib.optionals (helpers.hasIn "hardware" "sound") [
      pavucontrol
      easyeffects
    ]
    ++ lib.optionals (helpers.hasIn "hardware" "print") [
      simple-scan
      sane-frontends
    ]
    ++ lib.optionals (helpers.hasIn "services" "virtual-machine") [
      virt-manager
    ];
}
