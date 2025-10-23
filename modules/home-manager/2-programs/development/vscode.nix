{ config, pkgs, ... }:
let
  vscode = pkgs.vscode.overrideAttrs (oldAttrs: {
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.makeWrapper ];

    postFixup = (oldAttrs.postFixup or "") + ''
      wrapProgram $out/bin/code \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--disable-gpu"
    '';
  });
in
{
  programs.vscode = {
    enable = true;
    package = vscode;
    mutableExtensionsDir = true;

    profiles.default = {
      userSettings = {
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
        "editor.fontSize" = 18;
        "window.zoomLevel" = 1;

        "workbench.iconTheme" = "bearded-icons";
        "workbench.colorTheme" = "base16-ayu-dark";

        "editor.formatOnSave" = false;
        "editor.formatOnPaste" = false;
        "editor.codeActionsOnSave" = {
          "source.fixAll.eslint" = "explicit";
          "source.organizeImports" = "explicit";
        };

        "errorLens.enabled" = true;
        "errorLens.enabledDiagnosticLevels" = [
          "error"
          "warning"
          "info"
          "hint"
        ];
        "errorLens.fontSize" = "14";
        "errorLens.fontWeight" = "bold";
        "errorLens.fontStyleItalic" = true;
        "errorLens.gutterIconsEnabled" = true;
        "errorLens.messageTemplate" = "$message";
        "errorLens.delay" = 0;

        "problems.showCurrentInStatus" = true;
        "problems.sortOrder" = "severity";

        "editor.tabSize" = 2;
        "editor.detectIndentation" = false;
        "editor.lineNumbers" = "relative";
        "workbench.tree.indent" = 14;
        "files.insertFinalNewline" = true;

        "workbench.sideBar.location" = "left";
        "workbench.statusBar.visible" = false;
        "workbench.activityBar.location" = "hidden";
        "workbench.editor.showTabs" = "single";
        "workbench.startupEditor" = "none";
        "chat.commandCenter.enabled" = false;
        "workbench.layoutControl.enabled" = false;
        "window.customTitleBarVisibility" = "never";
        "window.titleBarStyle" = "native";
        "window.menuBarVisibility" = "toggle";

        "editor.scrollbar.vertical" = "hidden";
        "editor.scrollbar.horizontal" = "hidden";
        "editor.minimap.enabled" = true;
        "editor.minimap.renderCharacters" = false;

        "editor.multiCursorModifier" = "ctrlCmd";
        "editor.cursorBlinking" = "solid";
        "editor.matchBrackets" = "never";
        "editor.occurrencesHighlight" = "off";

        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = true;
        #"editor.guides.bracketPairsHorizontal" = true;
        #"editor.guides.highlightActiveIndentation" = true;

        "editor.lightbulb.enabled" = "off";
        "editor.showFoldingControls" = "never";
        "breadcrumbs.enabled" = false;
        "workbench.tips.enabled" = false;

        "editor.overviewRulerBorder" = false;
        "editor.hideCursorInOverviewRuler" = true;

        "editor.stickyScroll.enabled" = false;
        "workbench.tree.enableStickyScroll" = false;

        "explorer.confirmDragAndDrop" = true;
        "explorer.confirmDelete" = true;
        "explorer.decorations.badges" = false;
        "workbench.tree.renderIndentGuides" = "none";

        "git.decorations.enabled" = false;
        "scm.diffDecorations" = "none";

        "files.autoSave" = "afterDelay";
        "editor.wordWrap" = "on";
        "update.mode" = "none";

        #"extensions.ignoreRecommendations" = true;
        "[python]" = {
          "editor.defaultFormatter" = "ms-python.autopep8";
          "editor.formatOnSave" = true;
          "editor.tabSize" = 4;
        };

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.formatterPath" = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
        
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
        };
        
        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {
              "command" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
            };
            "options" = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"/home/${config.home.username}/nixos\").nixosConfigurations.desktop.options";
              };
              "home-manager" = {
                "expr" = "(builtins.getFlake \"/home/${config.home.username}/nixos\").homeConfigurations.desktop.options";
              };
            };
          };
        };
      };
      keybindings = [
        {
          key = "alt+d";
          command = "workbench.view.explorer";
        }
        {
          key = "alt+g";
          command = "workbench.view.scm";
        }
        {
          key = "alt+x";
          command = "workbench.view.extensions";
        }
        {
          key = "alt+t";
          command = "workbench.action.terminal.toggleTerminal";
        }

        # ===== ДОПОЛНИТЕЛЬНЫЕ ПОЛЕЗНЫЕ БИНДИНГИ =====

        # Debug панель
        {
          key = "ctrl+5";
          command = "workbench.view.debug";
        }
        # Search панель
        {
          key = "ctrl+6";
          command = "workbench.view.search";
        }

        # Скрыть/показать боковую панель
        {
          key = "ctrl+b";
          command = "workbench.action.toggleSidebarVisibility";
        }

        # Скрыть/показать панель (где терминал)
        {
          key = "ctrl+j";
          command = "workbench.action.togglePanel";
        }
      ];
    };
  };

  home.activation.makeVSCodeConfigWritable = let
    configPath = "${config.xdg.configHome}/Code/User/settings.json";
  in {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ -L ${configPath} ]; then
        install -m 0640 "$(readlink ${configPath})" ${configPath}
      fi
    '';
  };
}
