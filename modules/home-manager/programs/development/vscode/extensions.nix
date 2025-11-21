{ pkgsWithOverlay, ... }:
with pkgsWithOverlay.vscode-marketplace-release;
[
  ms-python.autopep8
  jnoortheen.nix-ide
  usernamehw.errorlens
  beardedbear.beardedicons
  tintedtheming.base16-tinted-themes
  ms-python.python
  vue.volar
  esbenp.prettier-vscode
  dbaeumer.vscode-eslint
  octref.vetur
  vue.volar
]
