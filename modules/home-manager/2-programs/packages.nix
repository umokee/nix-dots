{
  pkgs,
  lib,
  helpers,
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
      eclipses.eclipse-cpp
    ]
    ++ lib.optionals (helpers.hasIn "hardware" "sound") [
      pavucontrol
      easyeffects
    ]
    ++ lib.optionals (helpers.hasIn "hardware" "print") [
      simple-scan
      sane-frontends
    ]
    ++
      lib.optionals
        (helpers.hasIn "services" [
          "postgresql"
          "ms-sql"
        ])
        [
          dbgate
        ]
    ++ lib.optionals (helpers.hasIn "services" "virtual-machine") [
      virt-manager
    ];
}
