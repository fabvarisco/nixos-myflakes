{ pkgs, inputs, ... }:

{
  users.users.fabvarisco = {
    isNormalUser = true;
    description = "Fabricio Varisco Oliveira";
    extraGroups = [ "wheel" "bluetooth" "audio" ];
    packages = with pkgs; [
      tree

      # Qt/GTK theming
      kdePackages.breeze
      kdePackages.breeze-icons
      adwaita-icon-theme
      gnome-themes-extra
      papirus-icon-theme

      # Browser & social
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      vesktop
      simplescreenrecorder

      # File managers
      nautilus
      yazi

      # Niri shell (waybar, notifications, launcher)
      waybar
      swaynotificationcenter
      libnotify
      noctalia-shell

      # Theming
      pywal

      # Audio
      pwvucontrol
      pamixer
      playerctl
      wiremix
      kdePackages.oxygen-sounds

      # Brightness
      brightnessctl

      # Network TUI
      impala

      # Bluetooth
      blueman

      # Screenshots
      grim
      slurp
      swappy

      # Clipboard
      wl-clipboard

      # Wallpaper
      swww

      # Misc
      imagemagick
      socat
      jq
    ];
  };
}
