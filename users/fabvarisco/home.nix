{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../home/cursor/twilight.nix
    ../../home/zen.nix
    ../../home/vicinae.nix
  ];

  home.username = "fabvarisco";
  home.homeDirectory = "/home/fabvarisco";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Hyprland
    waybar
    hyprlock
    wlogout
    hypridle
    swww
    hyprpaper
    hyprmon
    nwg-dock-hyprland
    
    # Screen recording
    simplescreenrecorder

    # Pywal
    pywal
    pywalfox-native

    # Notifications
    swaynotificationcenter
    libnotify

    # Qt/GTK theming
    kdePackages.breeze
    kdePackages.breeze-icons
    adwaita-icon-theme

    # Áudio
    wiremix
    pwvucontrol
    pamixer
    playerctl

    # Bluetooth
    blueman

    # Network
    impala

    # Brilho + OSD
    brightnessctl
    avizo

    # Social / Browser
    discord
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.snappy-switcher.packages.${pkgs.system}.default
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -f "$HOME/.cache/wal/starship.toml" ]; then
        export STARSHIP_CONFIG="$HOME/.cache/wal/starship.toml"
      fi
      eval "$(starship init bash)"
      fastfetch
    '';
  };

  # Configs
  home.file.".config/hypr".source = ../../config/hypr;
  home.file.".config/waybar".source = ../../config/waybar;
  home.file.".config/kitty".source = ../../config/kitty;
  home.file.".config/btop".source = ../../config/btop;
  home.file.".config/starship.toml".source = ../../config/starship.toml;
  home.file.".config/swaync".source = ../../config/swaync;
  home.file.".config/kde".source = ../../config/kde;

  # Wallpapers e avatares
  home.file.".config/walls".source = ../../config/walls;
  home.file.".config/profile-pics".source = ../../config/profile-pics;

  # Pywal templates
  home.file.".config/wal/templates".source = ../../config/wal/templates;

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
