{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    bat
    lsd
    btop
    wl-clipboard
    inxi
    tree
    exfatprogs
    libva-utils
    ffmpeg
    ffmpegthumbnailer
    gftp

    glib
    gsettings-desktop-schemas
    gtk3
    dconf

    arj
    lha
    lrzip
    lzop
    p7zip
    pbzip2
    pigz
    pixz
    unrar
    unzip
    zip
    brotli
    cpio
  ];
}
