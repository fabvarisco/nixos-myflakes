{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.vicinae.homeManagerModules.default ];

  home.username = "fabvarisco";
  home.homeDirectory = "/home/fabvarisco";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    pywal
    pywalfox-native
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    inputs.hyprswitch.packages.${pkgs.system}.default
  ];

  # Cursor Twilight
  home.pointerCursor = {
    name = "Twilight";
    package = pkgs.stdenvNoCC.mkDerivation {
      pname = "twilight-cursor-theme";
      version = "2024.02.14";
      src = pkgs.fetchFromGitHub {
        owner = "yeyushengfan258";
        repo = "Twilight-Cursors";
        rev = "ca9c69f7632fda345d71bd6062de136d77924fe9";
        sha256 = "sha256-8HENtltZVmCybcS6o8rRQ306ZkNCCz8eF7eYaxYQgfE=";
      };
      installPhase = ''
        mkdir -p $out/share/icons/Twilight
        cp -r dist/* $out/share/icons/Twilight/
      '';
    };
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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
  home.file.".config/hypr".source = ./config/hypr;
  home.file.".config/waybar".source = ./config/waybar;
  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/btop".source = ./config/btop;
  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".config/swaync".source = ./config/swaync;
  home.file.".config/zen".source = ./config/zen;
  home.file.".config/kde".source = ./config/kde;
  home.file.".local/share/zen-startpage".source = ./config/zen/startpage;

  # Wallpapers e avatares
  home.file.".config/walls".source = ./config/walls;
  home.file.".config/profile-pics".source = ./config/profile-pics;

  # Pywal templates
  home.file.".config/wal/templates".source = ./config/wal/templates;

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

  # Zen Browser setup - copy config files to profile directories
  home.activation.zenBrowserSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ZEN_DIR="$HOME/.zen"
    ZEN_CONFIG="$HOME/.config/zen"

    if [ -d "$ZEN_DIR" ]; then
      for profile in "$ZEN_DIR"/*; do
        if [ -d "$profile" ] && [[ "$(basename "$profile")" != "Profile Groups" ]]; then
          mkdir -p "$profile/chrome"

          # Copy userChrome.css
          if [ -f "$ZEN_CONFIG/userChrome.css" ]; then
            rm -f "$profile/chrome/userChrome.css" 2>/dev/null
            cp "$ZEN_CONFIG/userChrome.css" "$profile/chrome/userChrome.css"
          fi

          # Copy user.js
          if [ -f "$ZEN_CONFIG/user.js" ]; then
            rm -f "$profile/user.js" 2>/dev/null
            cp "$ZEN_CONFIG/user.js" "$profile/user.js"
          fi
        fi
      done
    fi
  '';

  # Vicinae launcher
  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = "1";
      };
    };
    settings = {
      close_on_focus_loss = true;
      pop_to_root_on_close = true;
      terminal = "kitty";
      font.normal = {
        size = 10;
        family = "JetBrains Mono Nerd Font";
      };
      launcher_window.opacity = 1.0;
    };
  };
}
