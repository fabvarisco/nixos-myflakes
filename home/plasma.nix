{ config, pkgs, lib, ... }:

{
  imports = [
    ./plasma-theme.nix
  ];

  home.packages = with pkgs; [
    kdePackages.kate
  ];

  # KDE config
  home.file.".config/kdeglobals".source = ../config/plasma/kdeglobals;
}
