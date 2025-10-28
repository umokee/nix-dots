{ pkgs }:

pkgs.mkShell {
  name = "python-dev";
  
  nativeBuildInputs = with pkgs; [
    pkg-config
    qt6.wrapQtAppsHook
  ];
  
  buildInputs = with pkgs; [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    
    gtk3
    gtk4
    gobject-introspection
    
    wayland
    libxkbcommon
    xorg.libX11
    xorg.libxcb
    
    libGL
    mesa
    
    (python3.withPackages (ps: with ps; [
      pyside6
      pyqt6
      tkinter
      pygobject3
      numpy
      pandas
      matplotlib
      scipy
      openai
      requests
      pip
      setuptools
      wheel
      pytest
      black
      pylint
      ipython
    ]))
  ];

  shellHook = ''
    export QT_QPA_PLATFORM="xcb"
    export QT_PLUGIN_PATH="${pkgs.qt6.qtbase}/lib/qt-6/plugins"
    
    export DISPLAY="''${DISPLAY:-:0}"
    export WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-wayland-1}"
    
    export GDK_BACKEND=x11
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share"
    
    echo "Python Dev Environment"
  '';
}
