{
  lib,
  helpers,
  pkgs,
  ...
}:
let
  enable = helpers.hasIn "workspace" "mangowc";
  mainBtn = "SUPER";
in
{
  config = lib.mkIf enable {
    home.file.".config/mango/binds.conf".text = ''
      bind=${mainBtn}+SHIFT,R,reload_config
      bind=${mainBtn},m,quit

      bind=${mainBtn},a,spawn,${pkgs.tofi}/bin/tofi-drun --drun-launch=true
      bind=${mainBtn},Return,spawn,foot
      bind=${mainBtn},w,spawn,zen
      bind=${mainBtn},e,spawn,nemo
      bind=,Print,spawn,screenshot-tool area
      bind=${mainBtn},b,spawn_shell,pkill waybar || waybar &

      bind=${mainBtn},Tab,focusstack,next

      bind=${mainBtn}+SHIFT,K,exchange_client,up
      bind=${mainBtn}+SHIFT,J,exchange_client,down
      bind=${mainBtn}+SHIFT,H,exchange_client,left
      bind=${mainBtn}+SHIFT,L,exchange_client,right

      bind=${mainBtn},g,toggleglobal,
      bind=${mainBtn}+SHIFT,Tab,toggleoverview,
      bind=${mainBtn},f,togglemaxmizescreen, # togglefakefullscreen
      bind=${mainBtn},v,togglefloating,
      bind=${mainBtn},i,minimized,R
      bind=${mainBtn}+SHIFT,I,restore_minimized
      bind=${mainBtn},q,killclient,

      bind=${mainBtn},h,viewtoleft_have_client,0
      bind=${mainBtn},l,viewtoright_have_client,0
      bind=${mainBtn},j,tagtoleft,0
      bind=${mainBtn},k,tagtoright,0

      bind=${mainBtn},1,view,1,0
      bind=${mainBtn},2,view,2,0
      bind=${mainBtn},3,view,3,0
      bind=${mainBtn},4,view,4,0
      bind=${mainBtn},5,view,5,0
      bind=${mainBtn},6,view,6,0
      bind=${mainBtn},7,view,7,0
      bind=${mainBtn},8,view,8,0
      bind=${mainBtn},9,view,9,0

      # tag, tagsilent
      bind=${mainBtn}+SHIFT,1,tag,1,0
      bind=${mainBtn}+SHIFT,2,tag,2,0
      bind=${mainBtn}+SHIFT,3,tag,3,0
      bind=${mainBtn}+SHIFT,4,tag,4,0
      bind=${mainBtn}+SHIFT,5,tag,5,0
      bind=${mainBtn}+SHIFT,6,tag,6,0
      bind=${mainBtn}+SHIFT,7,tag,7,0
      bind=${mainBtn}+SHIFT,8,tag,8,0
      bind=${mainBtn}+SHIFT,9,tag,9,0

      # resizewin
      #bind=CTRL+ALT,Up,resizewin,+0,-50
      #bind=CTRL+ALT,Down,resizewin,+0,+50
      #bind=CTRL+ALT,Left,resizewin,-50,+0
      #bind=CTRL+ALT,Right,resizewin,+50,+0

      # Mouse Button Bindings
      mousebind=${mainBtn},btn_left,moveresize,curmove
      mousebind=${mainBtn},btn_right,moveresize,curresize
      axisbind=${mainBtn},UP,viewtoleft_have_client
      axisbind=${mainBtn},DOWN,viewtoright_have_client
    '';
  };
}
