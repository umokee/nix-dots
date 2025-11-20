{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    package = pkgs.starship;

    settings = {
      add_newline = false;
      command_timeout = 1000;
      format = "$all$nix_shell$character";

      character = {
        success_symbol = "[➜](bold cyan)";
        error_symbol = "[✗](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
        deleted = "x";
      };

      nix_shell = {
        symbol = " ";
        format = "[$symbol$state]($style) ";
        style = "bold blue";
      };

      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow) ";
      };
    };
  };
}
