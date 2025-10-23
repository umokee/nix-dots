{
  lib,
  pkgs,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "users";
in
{
  config = lib.mkIf enable {
    users.users.${conf.username} = {
      isNormalUser = true;
      description = "Main user";
      extraGroups = [
        "wheel"
        "networkmanager"
        "input"
      ]
      ++ lib.optionals (helpers.hasIn "hardware" "sound") [
        "sound"
      ]
      ++
        lib.optionals
          (helpers.hasIn "hardware" [
            "nvidia"
            "amd"
          ])
          [
            "video"
            "render"
          ];
      shell = pkgs.bash;
    };
  };
}
