{ pkgs, config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      gcc
      gnumake
      unzip
      git

      # Инструменты поиска для Telescope
      ripgrep
      fd

      # Tree-sitter CLI
      tree-sitter

      # LSP серверы
      nil # Nix
      lua-language-server # Lua
      nodePackages.vscode-langservers-extracted # JavaScript
      nodePackages.typescript-language-server # TypeScript

      # Форматтеры
      stylua # Lua
      nixfmt-rfc-style # Nix
      black # Python
      nodePackages.prettier # JavaScript
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim

      # Базовые плагины
      plenary-nvim
      nvim-web-devicons

      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim

      # LSP
      nvim-lspconfig
      fidget-nvim

      # Treesitter
      (nvim-treesitter.withPlugins (p: [
        p.bash
        p.c
        p.diff
        p.html
        p.lua
        p.luadoc
        p.markdown
        p.markdown_inline
        p.query
        p.vim
        p.vimdoc
        p.nix
        p.javascript
        p.typescript
      ]))
      nvim-treesitter-textobjects

      # UI и удобства
      which-key-nvim
      gitsigns-nvim
      todo-comments-nvim
      mini-nvim
      
      # Тема
      tokyonight-nvim
      
      # Автоматическое определение отступов
      guess-indent-nvim
      
      # Форматирование
      conform-nvim
    ];
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/nixos/modules/home-manager/programs/development/nvim/config";
    recursive = true;
  };
}
