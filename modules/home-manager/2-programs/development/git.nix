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

      ignores = [
        ".vscode/"
        ".idea/"
        "__pycache__/"
        ".syncrclone"
      ];
    };
  };
}
