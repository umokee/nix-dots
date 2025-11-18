{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  pythonWithPackages = pkgs.python3.withPackages (
    ps: with ps; [
      pytubefix
      requests
      numpy
      pillow
      cairosvg
      autopep8
    ]
  );
in
{
  home.packages =
    with pkgs;
    [ ]
    ++ lib.optionals (helpers.hasIn "programs" "nodejs") [
      nodejs_20
      yarn
      pnpm
      nodePackages.prettier
      nodePackages.eslint
      nodePackages.vscode-langservers-extracted
    ]
    ++ lib.optionals (helpers.hasIn "programs" "dotnet") [
      dotnet-sdk_9
    ]
    ++ lib.optionals (helpers.hasIn "programs" "nix-lang") [
      nixd
      nixfmt
      nixd
    ]
    ++ lib.optionals (helpers.hasIn "programs" "python-lang") [
      pythonWithPackages
    ];
}
