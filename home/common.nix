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
      if [ -f "$HOME/.cache/wal/starship.toml" ]; then
        export STARSHIP_CONFIG="$HOME/.cache/wal/starship.toml"
      fi
      eval "$(starship init bash)"
      bash ~/.config/fastfetch/random-logo.sh
    '';
  };
}
