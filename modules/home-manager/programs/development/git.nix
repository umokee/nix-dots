{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      gh
    ];

    programs.git = {
      enable = true;
      package = pkgs.git;

      settings = {
        user = {
          name = "umokee";
          email = "hituaev@gmail.com";
        };
        init.defaultBranch = "main";
      };

      ignores = [
        ".vscode/"
        ".idea/"
        "__pycache__/"
        ".syncrclone/"
        "node_modules/"
        "tags"
        "test.sh"
        ".luarc.json"
        "spell/"
        "lazy-lock.json"
      ];
    };
    
    programs.diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
