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

    plugins = [ ];
  };

  # Symlink на всю папку config
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/home-manager/programs/development/nvim/config";
    recursive = true;
  };
}
