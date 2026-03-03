{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gum
    yazi
    unzip
    zip
    p7zip
    btop
    imv
    mpv
    vlc
  ];
}
