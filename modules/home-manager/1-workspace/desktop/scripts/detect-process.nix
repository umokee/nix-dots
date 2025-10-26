{
  pkgs,
  ...
}:
{
  config = {
    home.file.".local/bin/detect-process" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash


      '';
    };
  };
}
