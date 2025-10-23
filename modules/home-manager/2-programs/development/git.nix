{ config, pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      gh
    ];

    programs.git = {
      enable = true;
      package = pkgs.git;

      diff-so-fancy.enable = true;
      userName = "umokee";
      userEmail = "hituaev@gmail.com";
        
      extraConfig = {
        credential."https://github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";
        credential."https://gist.github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";
      };

      ignores = [
        ".vscode/"
        ".idea/"
        "__pycache__/"
        ".syncrclone"
      ];
    };
  };
}
