{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    kdePackages.kate
  ];

  # KDE default config - no custom theming
  # The kdeglobals file is removed to let Plasma use its default settings
}
