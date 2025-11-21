{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "kanata";
in
{
  config = lib.mkIf enable {
    services.kanata = {
      enable = true;
      package = pkgs.kanata;

      keyboards = {
        default = {
          extraDefCfg = ''
            concurrent-tap-hold yes
            process-unmapped-keys true
          '';

          config = ''
(defsrc
  esc q w e r t enter
  lctrl a s d f g lalt
  lshift z x c v b
  super mo1 spc mo2 rshift
  
  p o i u y enter
  l k j h scolon ralt
  m n comma dot slash
  enter
)

;; ============ АЛИАСЫ - РУССКИЕ БУКВЫ ============
(defalias
  й й
  ц ц
  у у
  к к
  е е
  ф ф
  ы ы
  в в
  а а
  п п
  я я
  ч ч
  с с
  м м
  и и
  н н
  г г
  ш ш
  щ щ
  з з
  р р
  о о
  л л
  д д
  ж ж
  э э
  т т
  ь ь
  б б
  ю ю
  х х
  
  sym (layer-while-held symbols)
)

;; ============ LAYER 0 - BASE (РУССКИЙ COLEMAK) ============
(deflayer base
  esc @й @ц @у @к @е ent
  lctrl @ф @ы @в @а @п lalt
  lshift @я @ч @с @м @и
  super @sym spc @sym rshift
  
  @н @г @ш @щ @з ent
  @л @д @ж @р @о ralt
  @т @ь @б @ю @х
  ent
)

;; ============ LAYER 1 - SYMBOLS (СИМВОЛЫ) ============
(deflayer symbols
  esc ! @ # $ % _
  lctrl 1 2 3 4 5 lalt
  lshift 6 7 8 9 0
  super @sym spc @sym rshift
  
  ^ & * ( ) _
  - = [ ] bsls ralt
  _ ; : ' slash
  _
)
          '';
        };
      };
    };
  };
}
