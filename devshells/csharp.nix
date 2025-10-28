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
    libX11
    libICE
    libSM
    
    # Wayland/X11 поддержка
    wayland
    xorg.libX11
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
    export DOTNET_ROOT="${pkgs.dotnet-sdk_8}"
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
    
    # GUI поддержка
    export GDK_BACKEND=wayland,x11
    export WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-wayland-0}"
    export DISPLAY="''${DISPLAY:-:0}"
    
    # Для работы с системными файлами и настройками
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share:${pkgs.gsettings-desktop-schemas}/share"
    export LD_LIBRARY_PATH="${pkgs.fontconfig.lib}/lib:${pkgs.libGL}/lib:$LD_LIBRARY_PATH"
    
    echo "# C# Dev Environment"
  '';
}
