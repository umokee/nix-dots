{
  config,
  pkgs,
  lib,
  helpers,
  ...
}:
let
  pythonWithPackages = pkgs.python3.withPackages (
    ps: with ps; [
      pytubefix
      requests
      numpy
      pillow
      cairosvg
      autopep8
    ]
  );

  avaloniaLibs = with pkgs; [
    # X11 библиотеки
    xorg.libX11
    xorg.libICE
    xorg.libSM
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXext
    xorg.libXrender
    xorg.libXfixes
    
    # Графика и рендеринг
    fontconfig
    fontconfig.lib
    freetype
    libGL
    libglvnd
    libxkbcommon
    
    # Системные библиотеки
    glib
    icu
    openssl
    zlib
    stdenv.cc.cc.lib
    
    # Дополнительно для .NET
    krb5
    lttng-ust_2_12
  ];

  dotnet-avalonia-fhs = pkgs.buildFHSEnv {
    name = "dotnet";
    
    targetPkgs = pkgs: [
      pkgs.dotnet-sdk_9
    ] ++ avaloniaLibs;
    
    multiPkgs = pkgs: avaloniaLibs;
    
    runScript = "dotnet";
    
    profile = ''
      export DOTNET_ROOT=${pkgs.dotnet-sdk_9}
      export FONTCONFIG_PATH=${pkgs.fontconfig.out}/etc/fonts
      export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
    '';
  };
in
{
  home.packages =
    with pkgs;
    [ ]
    ++ lib.optionals (helpers.hasIn "programs" "nodejs") [
      nodejs_20
      yarn
      pnpm
    ]
    ++ lib.optionals (helpers.hasIn "programs" "dotnet") (
      [
        dotnet-avalonia-fhs
      ]
    )
    ++ lib.optionals (helpers.hasIn "programs" "nix-lang") [
      nixd
      nixfmt
    ]
    ++ lib.optionals (helpers.hasIn "programs" "python-lang") [
      pythonWithPackages
    ];
}
