{
  config,
  lib,
  helpers,
  pkgs,
  ...
}:
let
  enable = helpers.hasIn "workspace" "mangowc";
  color = config.colorScheme.color;
in
{
  config = lib.mkIf enable {
    programs.bash.profileExtra = lib.mkIf helpers.isWM ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec mango
      fi
    '';

    wayland.windowManager.mango = {
      enable = true;
      settings = ''
        # https://github.com/DreamMaoMao/mango/wiki/

        # Window effect
        blur=0
        blur_layer=0

        shadows = 0
        layer_shadows = 0
        shadow_only_ing = 1
        shadows_size = 10
        shadows_blur = 15
        shadows_position_x = 0
        shadows_position_y = 0
        shadowscolor= 0x000000ff

        # Animation Configuration
        animations=0
        layer_animations=0

        # Scroller Layout Setting
        scroller_structs=20
        scroller_default_proportion=1.0
        scroller_focus_center=0
        scroller_prefer_center=0
        edge_scroller_pointer_focus=1
        scroller_default_proportion_single=1.0
        scroller_proportion_preset=0.5,0.8,1.0

        # Master-Stack Layout Setting
        new_is_master=1
        default_mfact=0.55
        default_nmaster=1
        smartgaps=0

        # Overview Setting
        hotarea_size=10
        enable_hotarea=0
        ov_tab_mode=0
        overviewgappi=2
        overviewgappo=10

        # Misc
        no_border_when_single=0
        axis_bind_apply_timeout=100
        focus_on_activate=0
        inhibit_regardless_of_visibility=0
        sloppyfocus=1
        warpcursor=1
        focus_cross_monitor=0
        focus_cross_tag=0
        enable_ing_snap=0
        snap_distance=30
        cursor_size=24
        drag_tile_to_tile=1

        # Mouse
        mouse_natural_scrolling=0

        # Keyboard
        repeat_rate=50
        repeat_delay=300
        numlockon=0
        xkb_rules_layout=us,ru
        xkb_rules_options=grp:ctrl_shift_toggle

        # Trackpad
        disable_trackpad=${if helpers.isLaptop then "1" else "0"}
        tap_to_click=1
        tap_and_drag=1
        drag_lock=1
        trackpad_natural_scrolling=0
        disable_while_typing=1
        left_handed=0
        middle_button_emulation=0
        swipe_min_threshold=1

        # Appearance
        border_radius=0
        no_radius_when_single=0
        focused_opacity=1.0
        unfocused_opacity=1.0
        borderpx=1
        gappih=2
        gappiv=2
        gappoh=2
        gappov=2
        scratchpad_width_ratio=0.8
        scratchpad_height_ratio=0.9

        rootcolor=0x${color.base00}ff
        bordercolor=0x${color.base03}ff
        focuscolor=0x${color.base0E}ff
        maxmizescreencolor=0x${color.base0B}ff
        urgentcolor=0x${color.base08}ff
        scratchpadcolor=0x${color.base0D}ff
        globalcolor=0x${color.base0E}ff
        overlaycolor=0x${color.base0C}ff

        source=~/.config/mango/binds.conf
        source=~/.config/mango/rules.conf
      '';
      autostart_sh = ''
        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &
        systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &
      '';
    };
  };
}
