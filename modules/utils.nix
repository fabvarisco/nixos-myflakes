{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gum
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
