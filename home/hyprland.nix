{ config, pkgs, user, ... }:

{
  imports = [
    ./nautilus.nix
    ./vicinae.nix
    ./noctalia.nix
    ./cursor/aosp.nix
  ];

  home.packages = with pkgs; [
    # File managers (Hyprland exclusive)
    nautilus
    yazi

    # Hyprland ecosystem
    hyprlock
    hypridle
    hyprmon
    hyprpolkitagent

    # Notifications
    libnotify

    # Sound effects (pw-play is provided by pipewire, already in system packages)
    kdePackages.oxygen-sounds

    # Brightness control
    brightnessctl

    # Audio
    pwvucontrol
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
}
