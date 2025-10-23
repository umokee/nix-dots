{
  config,
  lib,
  pkgs,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "users";

  cfg = {
    extraUsers = [ ];
  };
in
{
  config = lib.mkIf enable {
    users.users = lib.mkMerge [
      {
        ${conf.username} = {
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
      }

      (builtins.listToAttrs (
        map (user: {
          name = user.name;
          value = {
            isNormalUser = true;
            description = user.description or "";
            extraGroups = user.groups or [ ];
            shell = user.shell or pkgs.bash;
          };
        }) cfg.extraUsers
      ))
    ];
  };
}
