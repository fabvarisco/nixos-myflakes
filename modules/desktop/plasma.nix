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
    kdePackages.kate
    kdePackages.spectacle
    kdePackages.dolphin
    kdePackages.ark
  ];

  # XDG portal for Plasma
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # Plasma config symlinks
  systemd.tmpfiles.rules = [
    "L+ /home/fabvarisco/.config/kdeglobals - - - - ${../../config/plasma/kdeglobals}"
    "L+ /home/fabvarisco/.config/ksplashrc - - - - ${../../config/plasma/ksplashrc}"
    "L+ /home/fabvarisco/.config/kscreenlockerrc - - - - ${../../config/plasma/kscreenlockerrc}"
  ];
}
