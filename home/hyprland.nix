{ config, pkgs, ... }:

{
  imports = [
    ./nautilus.nix
    ./vicinae.nix
    ./ags.nix
  ];

  home.packages = with pkgs; [
    # File managers (Hyprland exclusive)
    nautilus
    yazi

    # Hyprland ecosystem
    hyprlock
    hypridle
    swww
    hyprpaper
    hyprmon

    # Notifications (libnotify for notify-send)
    libnotify

    # Sound effects
    libcanberra-gtk3
    sound-theme-freedesktop

    # Audio (Hyprland doesn't have built-in mixer)
    wiremix

    # Network TUI
    impala

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

  # Matugen config and templates
  home.file.".config/matugen/config.toml".source = ../config/shared/matugen/config.toml;
  home.file.".config/matugen/templates".source = ../config/shared/matugen/templates;

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
