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
      #discord
      (termius.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [ sqlite ];
      }))
      nmap
      inputs.waterfox.packages.x86_64-linux.default
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
