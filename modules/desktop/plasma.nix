{ config, lib, pkgs, ... }:

{
  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";

  # SDDM with SilentSDDM theme (configured in common.nix)

  # NetworkManager for Plasma WiFi applet (uses iwd as backend)
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

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
