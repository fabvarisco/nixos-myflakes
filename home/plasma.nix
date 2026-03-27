{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    kdePackages.kate
  ];

  # KDE theme config - Moe-Dark with Ant-Dark icons
  home.file.".config/kdeglobals".source = ../config/plasma/kdeglobals;

  # Splash screen - Lagtrain
  home.file.".config/ksplashrc".source = ../config/plasma/ksplashrc;

  # Lock screen - lock.jpg
  home.file.".config/kscreenlockerrc".source = ../config/plasma/kscreenlockerrc;

  # Wallpapers folder (for slideshow - configure manually in Plasma)
  home.file.".config/walls" = {
    source = ../config/walls;
    recursive = true;
  };
}
