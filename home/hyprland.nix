{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Hyprland ecosystem
    waybar
    hyprlock
    hypridle
    wlogout
    swww
    hyprpaper
    hyprmon
    nwg-dock-hyprland

    # Notifications
    swaynotificationcenter
    libnotify

    # OSD
    avizo

    # Pywal (theming)
    pywal
    pywalfox-native

    # Sound effects
    libcanberra-gtk3
    kdePackages.cla-sound-theme
    sound-theme-freedesktop

    # Audio (Hyprland doesn't have built-in mixer)
    wiremix

    # Network TUI
    impala

    # Brightness control
    brightnessctl
    
    # Audio
    pwvucontrol
    pamixer
    playerctl

    # Bluetooth
    blueman

    # Monitor auto-detection (for hyprmon-watch)
    socat
    jq
  ];

  # Hyprland configs
  home.file.".config/hypr".source = ../config/hyprland;
  home.file.".config/waybar".source = ../config/hyprland/waybar;
  home.file.".config/swaync".source = ../config/hyprland/swaync;
  home.file.".config/wlogout".source = ../config/hyprland/wlogout;

  # Pywal templates
  home.file.".config/wal/templates".source = ../config/shared/wal/templates;

  # Pywal default colors (fallback when pywal hasn't generated colors yet)
  home.file.".config/wal/colors-waybar-default.css".source = ../config/shared/wal/colors-waybar-default.css;
  home.file.".config/wal/colors-swaync-default.css".source = ../config/shared/wal/colors-swaync-default.css;

  # Pywalfox native messaging host
  home.file.".mozilla/native-messaging-hosts/pywalfox.json".text = ''
    {
      "name": "pywalfox",
      "description": "Pywalfox native messaging host",
      "path": "${pkgs.pywalfox-native}/bin/pywalfox",
      "type": "stdio",
      "allowed_extensions": ["pywalfox@frewacom.org"]
    }
  '';
}
