{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    clipse
    imagemagick
  ];
}
