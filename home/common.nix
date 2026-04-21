{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Qt/GTK theming
    kdePackages.breeze
    kdePackages.breeze-icons
    adwaita-icon-theme

    # Browser
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Screen recording
    simplescreenrecorder

    # Social
    vesktop
  ];

  # Shared configs
  home.file.".config/kitty".source = ../config/shared/kitty;
  home.file.".config/btop".source = ../config/shared/btop;
  home.file.".config/starship.toml".source = ../config/shared/starship.toml;
  home.file.".config/fastfetch".source = ../config/shared/fastfetch;
  home.file.".config/walls".source = ../config/walls;
  home.file.".config/profile-pics".source = ../config/profile-pics;

  # Bash
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(starship init bash)"
      bash ~/.config/fastfetch/random-logo.sh
    '';
  };
}
