{ config, lib, pkgs, inputs, ... }:

let
  pywalfoxManifest = pkgs.writeText "pywalfox.json" (builtins.toJSON {
    name = "pywalfox";
    description = "Pywalfox native messaging host";
    path = "${pkgs.pywalfox-native}/bin/pywalfox";
    type = "stdio";
    allowed_extensions = [ "pywalfox@frewacom.org" ];
  });

  gtkBookmarks = pkgs.writeText "gtk-bookmarks" ''
    file:///home/fabvarisco/Downloads Downloads
    file:///home/fabvarisco/Developer Developer
    file:///home/fabvarisco/Documents Documents
  '';
in

{
  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # XDG Portal for Hyprland (screen sharing, file dialogs, app communication)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  environment.systemPackages = with pkgs; [
    # Screenshot
    grim
    slurp
    swappy

    # Clipboard
    wl-clipboard
    clipse
    imagemagick

    # File managers
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

    # Notifications
    swaynotificationcenter
    libnotify

    # OSD
    avizo

    # Pywal (theming)
    pywal
    pywalfox-native

    # Sound effects
    kdePackages.oxygen-sounds

    # Audio
    wiremix
    pwvucontrol
    pamixer
    playerctl

    # Network TUI
    impala

    # Brightness control
    brightnessctl

    # Bluetooth
    blueman

    # Monitor auto-detection
    socat
    jq

    # GTK theming
    gnome-themes-extra
    papirus-icon-theme

    # Vicinae
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Config symlinks
  systemd.tmpfiles.rules = [
    "L+ /home/fabvarisco/.config/hypr - - - - ${../../config/hyprland}"
    "L+ /home/fabvarisco/.config/waybar - - - - ${../../config/hyprland/waybar}"
    "L+ /home/fabvarisco/.config/swaync - - - - ${../../config/hyprland/swaync}"
    "L+ /home/fabvarisco/.config/wlogout - - - - ${../../config/hyprland/wlogout}"
    "d /home/fabvarisco/.config/wal 0755 fabvarisco users -"
    "L+ /home/fabvarisco/.config/wal/templates - - - - ${../../config/shared/wal/templates}"
    "L+ /home/fabvarisco/.config/wal/colors-waybar-default.css - - - - ${../../config/shared/wal/colors-waybar-default.css}"
    "L+ /home/fabvarisco/.config/wal/colors-swaync-default.css - - - - ${../../config/shared/wal/colors-swaync-default.css}"
    "d /home/fabvarisco/.mozilla 0755 fabvarisco users -"
    "d /home/fabvarisco/.mozilla/native-messaging-hosts 0755 fabvarisco users -"
    "L+ /home/fabvarisco/.mozilla/native-messaging-hosts/pywalfox.json - - - - ${pywalfoxManifest}"
    "d /home/fabvarisco/.config/gtk-3.0 0755 fabvarisco users -"
    "L+ /home/fabvarisco/.config/gtk-3.0/bookmarks - - - - ${gtkBookmarks}"
  ];

  # Wallpaper slideshow service
  systemd.user.services.wallpaper-slideshow = {
    description = "Automatic wallpaper slideshow (changes every 12h)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash /home/fabvarisco/.config/hypr/wallpaper-slideshow.sh";
      Restart = "on-failure";
      RestartSec = "10";
    };
  };

  # Vicinae launcher service
  systemd.user.services.vicinae = {
    description = "Vicinae launcher/switcher";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    environment = {
      USE_LAYER_SHELL = "1";
    };
    serviceConfig = {
      ExecStart = "${inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/vicinae";
      Restart = "on-failure";
    };
  };

  # Nautilus dconf settings
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        show-hidden-files = true;
        default-sort-order = "name";
        default-sort-in-reverse-order = false;
        show-delete-permanently = true;
      };
      "org/gnome/nautilus/list-view" = {
        default-column-order = [ "name" "size" "type" "date_modified" ];
        default-visible-columns = [ "name" "size" "date_modified" ];
        use-tree-view = false;
      };
    };
  }];
}
