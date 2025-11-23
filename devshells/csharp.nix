{ pkgs }:

pkgs.mkShell {
  name = "csharp-dev";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    # .NET SDK
    dotnet-sdk_9

    # GUI библиотеки
    gtk3
    gtk4

    # Avalonia UI зависимости
    fontconfig
    xorg.libX11
    xorg.libICE
    xorg.libSM

    # Wayland/X11 поддержка
    wayland
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi

    # OpenGL для рендеринга
    libGL

    # Инструменты разработки
    omnisharp-roslyn
    netcoredbg
  ];

  shellHook = ''
    # Настройка .NET
    export DOTNET_ROOT="${pkgs.dotnet-sdk_9}"
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

    # GUI поддержка
    export GDK_BACKEND=wayland,x11
    export WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-wayland-0}"
    export DISPLAY="''${DISPLAY:-:0}"

    # Для работы с системными файлами и настройками
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share:${pkgs.gsettings-desktop-schemas}/share"

    # Критический путь для нативных библиотек
    export LD_LIBRARY_PATH="${
      pkgs.lib.makeLibraryPath [
        pkgs.fontconfig
        pkgs.libGL
        pkgs.xorg.libX11
        pkgs.xorg.libICE
        pkgs.xorg.libSM
        pkgs.xorg.libXrandr
        pkgs.xorg.libXcursor
        pkgs.xorg.libXi
        pkgs.wayland
        pkgs.stdenv.cc.cc.lib
      ]
    }:$LD_LIBRARY_PATH"

    echo "# C# Dev Environment"
  '';
}
