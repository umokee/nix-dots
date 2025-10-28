{ pkgs }:

pkgs.mkShell {
  name = "python-dev";
  
  nativeBuildInputs = with pkgs; [
    pkg-config
    qt6.wrapQtAppsHook
  ];
  
  buildInputs = with pkgs; [
    # Qt6 для PySide6
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    
    # GTK для tkinter и другие GUI библиотеки
    gtk3
    gtk4
    gobject-introspection
    
    # Wayland поддержка
    wayland
    
    # Python с пакетами
    (python3.withPackages (ps: with ps; [
      # GUI фреймворки
      pyside6
      pyqt6
      tkinter
      pygobject3
      
      # Научные библиотеки
      numpy
      pandas
      matplotlib
      scipy
      
      # API библиотеки
      openai
      requests
      
      # Утилиты
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
    export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}/platforms"
    export QT_PLUGIN_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
    export GDK_BACKEND=wayland,x11
    export QT_QPA_PLATFORM=wayland;xcb
    
    # Для работы с системными файлами
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share:${pkgs.gsettings-desktop-schemas}/share"
    
    echo "🐍 Python Dev Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 GUI Frameworks: PySide6, PyQt6, Tkinter, GTK"
    echo "🔧 Python: $(python --version)"
    echo "💾 Packages: NumPy, Pandas, OpenAI, Requests"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  '';
}
