{ pkgs, ... }:
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
        init.defaultBranch = "main";
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
