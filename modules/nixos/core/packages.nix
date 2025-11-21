{
  pkgs,
  lib,
  helpers,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      coreutils
      util-linux
      shadow
      curl
      wget
      nano
      vim
      git

      pciutils
      lsof
      gawk

      gnutar
      gzip
      unzip
      xz
      zstd
      lz4
      bzip2
      libarchive
    ]
    ++ lib.optionals (!helpers.isServer) [
      libnotify
      usbutils
      upower
      home-manager
    ];
}
