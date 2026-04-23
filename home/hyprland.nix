{ config, pkgs, ... }:

{
  imports = [
    ./nautilus.nix
    ./vicinae.nix
  ];

  home.packages = with pkgs; [
    # File managers (Hyprland exclusive)
    nautilus
    yazi

    # Hyprland ecosystem
    waybar
    hyprlock
    hypridle
    wlogout
    awww
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
    kdePackages.oxygen-sounds

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

  # Wallpaper slideshow service
  systemd.user.services.wallpaper-slideshow = {
    Unit = {
      Description = "Automatic wallpaper slideshow (changes every 12h)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.config/hypr/wallpaper-slideshow.sh";
      Restart = "on-failure";
      RestartSec = "10";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
