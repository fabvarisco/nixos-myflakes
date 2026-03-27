{ config, lib, pkgs, ... }:

{
  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";

  # SDDM with random wallpaper
  services.displayManager.sddm = {
    enable = true;
    theme = "where_is_my_sddm_theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [ pkgs.where-is-my-sddm-theme ];
    settings = {
      Theme = {
        Background = "/var/lib/sddm/current-wallpaper";
      };
    };
  };

  # Script to select random wallpaper on boot (copies only one image)
  system.activationScripts.sddm-random-wallpaper = lib.stringAfter [ "var" ] ''
    # Use nix store path directly (more reliable during boot)
    WALLS_DIR="${../.. + /config/walls}"
    TARGET="/var/lib/sddm/current-wallpaper"

    mkdir -p /var/lib/sddm

    if [ -d "$WALLS_DIR" ]; then
      WALL=$(${pkgs.findutils}/bin/find "$WALLS_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | ${pkgs.coreutils}/bin/shuf -n 1)
      if [ -n "$WALL" ]; then
        cp "$WALL" "$TARGET"
        chmod 644 "$TARGET"
      fi
    fi
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
