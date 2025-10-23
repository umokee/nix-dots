{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    coreutils
    util-linux
    shadow
    curl
    wget
    nano
    vim
    git

    pciutils
    usbutils
    upower
    lsof

    gawk
    libnotify

    gnutar
    gzip
    unzip
    xz
    zstd
    lz4
    bzip2
    libarchive

    home-manager
  ];
}
