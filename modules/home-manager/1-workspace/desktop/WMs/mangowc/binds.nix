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
      bind=${mainBtn}+SHIFT,code:27,reload_config
      bind=${mainBtn},code:58,quit

      bind=${mainBtn},code:38,spawn,${pkgs.tofi}/bin/tofi-drun --drun-launch=true
      bind=${mainBtn},Return,spawn,foot
      bind=${mainBtn},code:25,spawn,zen
      bind=${mainBtn},code:26,spawn,nemo
      bind=${mainBtn},code:39,spawn,screenshot-tool area
      bind=${mainBtn},code:56,spawn_shell,pkill waybar || waybar &

      bind=${mainBtn},Tab,focusstack,next

      bind=${mainBtn}+SHIFT,code:43,exchange_client,up
      bind=${mainBtn}+SHIFT,code:44,exchange_client,down
      bind=${mainBtn}+SHIFT,code:45,exchange_client,left
      bind=${mainBtn}+SHIFT,code:46,exchange_client,right

      bind=${mainBtn},code:42,toggleglobal,
      bind=${mainBtn}+SHIFT,Tab,toggleoverview,
      bind=${mainBtn},f,togglemaxmizescreen, # togglefakefullscreen
      bind=${mainBtn},code:55,togglefloating,
      bind=${mainBtn},i,minimized,R
      bind=${mainBtn}+SHIFT,I,restore_minimized
      bind=${mainBtn},code:24,killclient,

      bind=${mainBtn},code:43,viewtoleft_have_client,0
      bind=${mainBtn},code:44,viewtoright_have_client,0
      bind=${mainBtn},code:45,tagtoleft,0
      bind=${mainBtn},code:46,tagtoright,0

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
