{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gum
    nautilus
    yazi
    unzip
    zip
    p7zip
    btop
    imv
    mpv
    vlc
    cava
    cmatrix
  ];
}
