{ pkgs }:
{
  bind = [
    "Super, A, exec, ${pkgs.tofi}/bin/tofi-drun --drun-launch=true"
    "Super, Return, exec, foot"
    "Super, W, exec, zen"
    "Super, E, exec, nemo"
    "Super+Shift, S, exec, screenshot-tool clip"
    "Super, Q, killactive,"
    "Super, V, togglefloating"
    "Super, F, fullscreen,"
    "Super, h, movefocus, l"
    "Super, l, movefocus, r"
    "Super, k, movefocus, u"
    "Super, j, movefocus, d"
    "Super+Shift, h, movewindow, l"
    "Super+Shift, l, movewindow, r"
    "Super+Shift, k, movewindow, u"
    "Super+Shift, j, movewindow, d"
    "Super, 1, workspace, 1"
    "Super, 2, workspace, 2"
    "Super, 3, workspace, 3"
    "Super, 4, workspace, 4"
    "Super, 5, workspace, 5"
    "Super, 6, workspace, 6"
    "Super, 7, workspace, 7"
    "Super, 8, workspace, 8"
    "Super, 9, workspace, 9"
    "Super, 0, workspace, 10"
    "Super+Shift, 1, movetoworkspace, 1"
    "Super+Shift, 2, movetoworkspace, 2"
    "Super+Shift, 3, movetoworkspace, 3"
    "Super+Shift, 4, movetoworkspace, 4"
    "Super+Shift, 5, movetoworkspace, 5"
    "Super+Shift, 6, movetoworkspace, 6"
    "Super+Shift, 7, movetoworkspace, 7"
    "Super+Shift, 8, movetoworkspace, 8"
    "Super+Shift, 9, movetoworkspace, 9"
    "Super+Shift, 0, movetoworkspace, 10"
  ];

  bindm = [
    "Super, mouse:272, movewindow"
    "Super, mouse:273, resizewindow"
  ];

  bindel = [
    ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%"
    ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%"
  ];
}
