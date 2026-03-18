{ config, lib, pkgs, ... }:

{
  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";

  # Essential KDE apps
  environment.systemPackages = with pkgs; [
    kdePackages.spectacle    # screenshot
    kdePackages.dolphin      # file manager
    kdePackages.ark          # archives
  ];

  # XDG portal for Plasma
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
