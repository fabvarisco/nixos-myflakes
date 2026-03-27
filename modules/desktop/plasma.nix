{ config, lib, pkgs, ... }:

{
  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";

  # SDDM with lock.jpg wallpaper
  services.displayManager.sddm = {
    enable = true;
    theme = "where_is_my_sddm_theme";
    extraPackages = [
      (pkgs.where-is-my-sddm-theme.override {
        themeConfig.General = {
          background = "/var/lib/sddm/wallpaper.jpg";
        };
      })
    ];
  };

  # Copy lock.jpg for SDDM
  system.activationScripts.sddm-wallpaper = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/sddm
    cp "${../../config/walls/lock.jpg}" "/var/lib/sddm/wallpaper.jpg"
    chmod 644 "/var/lib/sddm/wallpaper.jpg"
  '';

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
