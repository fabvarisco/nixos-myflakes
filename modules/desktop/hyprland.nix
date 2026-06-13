{ config, lib, pkgs, inputs, ... }:


let
  system = pkgs.stdenv.hostPlatform.system;

  # Vicinae Extensions

  nixExtension = inputs.vicinae.packages.${system}.mkVicinaeExtension {
    pname = "nix";
    version = "0";
    src = "${inputs.vicinae-extensions}/extensions/nix";
  };
  
  bluetoothExtension = inputs.vicinae.packages.${system}.mkVicinaeExtension {
    pname = "bluetooth";
    version = "0";
    src = "${inputs.vicinae-extensions}/extensions/bluetooth";
  };

  agendaExtension = inputs.vicinae.packages.${system}.mkVicinaeExtension {
    pname = "agenda";
    version = "0";
    src = "${inputs.vicinae-extensions}/extensions/agenda";
  };
  # End Vicinae Extensions


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

  hostname = config.networking.hostName;

  hostConfigYuck = pkgs.writeText "host-config.yuck" ''
    (defvar has-backlight "${if hostname == "thinkpad" then "true" else "false"}")
  '';

  ewwWithHostConfig = pkgs.runCommand "eww-config" {} ''
    cp -r ${../../config/hyprland/eww}/. $out/
    chmod -R u+w $out
    cp ${hostConfigYuck} $out/host-config.yuck
  '';
in

{
  imports = [ ../vicinae.nix ];

  services.vicinae-launcher = {
    enable = true;
    extensions = [ nixExtension bluetoothExtension agendaExtension ];
  };

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
    imagemagick

    # File managers
    nautilus
    yazi

    # Hyprland ecosystem
    eww
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

    # Night light (EWW quick-settings)
    hyprshade

    # Bluetooth
    blueman

    # Monitor auto-detection
    socat
    jq

    # EWW widget dependencies
    upower
    inotify-tools
    wirelesstools
    bc
    python3

    # GTK theming
    gnome-themes-extra
    papirus-icon-theme
  ];

  # Config symlinks via home-manager
  home-manager.users.fabvarisco = {
    xdg.configFile = {
      "eww".source    = ewwWithHostConfig;
      "swaync".source = ../../config/hyprland/swaync;
      "wlogout".source = ../../config/hyprland/wlogout;
      "wal/templates".source                 = ../../config/shared/wal/templates;
      "wal/colors-eww-default.scss".source   = ../../config/shared/wal/colors-eww-default.scss;
      "wal/colors-swaync-default.css".source = ../../config/shared/wal/colors-swaync-default.css;
      "gtk-3.0/bookmarks".source = gtkBookmarks;
    };
    home.file.".mozilla/native-messaging-hosts/pywalfox.json".source = pywalfoxManifest;
  };

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
