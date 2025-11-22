{ pkgs, config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Системные зависимости через Nix
    extraPackages = with pkgs; [
      gcc
      gnumake
      unzip
      git
      ripgrep
      fd
      tree-sitter

      # LSP серверы
      nil
      lua-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript-language-server
      pyright

      # Форматтеры
      stylua
      nixfmt-rfc-style
      black
      nodePackages.prettier

      # Линтеры
      markdownlint-cli
    ];

    # Все плагины через Nix
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      plenary-nvim
      nvim-web-devicons

      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim

      # LSP
      nvim-lspconfig
      fidget-nvim

      # Completion
      blink-cmp
      luasnip
      lazydev-nvim

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
        p.python
      ]))
      nvim-treesitter-textobjects

      # UI
      which-key-nvim
      gitsigns-nvim
      todo-comments-nvim
      mini-nvim
      tokyonight-nvim
      guess-indent-nvim

      # Formatting & Linting
      conform-nvim
      nvim-lint

      # Опциональные
      indent-blankline-nvim
      nvim-autopairs
      neo-tree-nvim
      nui-nvim

      # Debug (опционально)
      nvim-dap
      nvim-dap-ui
      nvim-nio
      nvim-dap-go
    ];
  };

  # Symlink на всю папку config
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/home-manager/programs/development/nvim/config";
    recursive = true;
  };
}
