{ config, pkgs, user, ... }:

{
  imports = [
    ./nautilus.nix
    ./vicinae.nix
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    # File managers (Hyprland exclusive)
    nautilus
    yazi

    # Hyprland ecosystem
    hyprlock
    hypridle
    wlogout
    hyprmon
    hyprpolkitagent

    # Notifications
    libnotify

    # Sound effects (pw-play is provided by pipewire, already in system packages)
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

  # Hyprland configs (templated to substitute @USERNAME@ in hyprland.conf)
  home.file.".config/hypr".source = pkgs.runCommand "hypr-config" {} ''
    cp -r ${../config/hyprland} $out
    chmod -R u+w $out
    substituteInPlace $out/hyprland.conf \
      --subst-var-by USERNAME "${user.username}"
  '';
  home.file.".config/wlogout".source = ../config/hyprland/wlogout;

  # Polkit authentication agent (needed by NetworkManager wifi connect, hyprlock, etc)
  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland polkit authentication agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = "5";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

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
