{ pkgs, inputs, ... }:

let
  mikuCursor = pkgs.stdenvNoCC.mkDerivation {
    pname = "miku-cursor-theme";
    version = "2024.01.01";
    src = pkgs.fetchFromGitHub {
      owner = "supermariofps";
      repo = "hatsune-miku-windows-linux-cursors";
      rev = "main";
      sha256 = "sha256-HCHo4GwWLvjjnKWNiHb156Z+NQqliqLX1T1qNxMEMfE=";
    };
    installPhase = ''
      mkdir -p $out/share/icons/miku-cursor-linux
      cp -r miku-cursor-linux/* $out/share/icons/miku-cursor-linux/
    '';
  };
in

{
  users.users.fabvarisco = {
    isNormalUser = true;
    description = "Fabricio Varisco Oliveira";
    extraGroups = [ "wheel" "bluetooth" "audio" "gamemode" ];
    packages = with pkgs; [
      tree

      # Qt/GTK theming
      kdePackages.breeze
      kdePackages.breeze-icons
      adwaita-icon-theme
      mikuCursor

      # Browser + launcher
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Screen recording
      simplescreenrecorder

      # Social
      vesktop
    ];
  };

  environment.sessionVariables = {
    XCURSOR_THEME = "miku-cursor-linux";
    XCURSOR_SIZE = "38";
  };

  systemd.user.services.zen-browser-setup = {
    description = "Setup Zen browser profiles";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        let
          script = pkgs.writeShellScript "zen-setup" ''
            ZEN_DIR="$HOME/.zen"
            ZEN_CONFIG="$HOME/.config/zen"
            if [ -d "$ZEN_DIR" ]; then
              for profile in "$ZEN_DIR"/*; do
                name="$(basename "$profile")"
                if [ -d "$profile" ] && [ "$name" != "Profile Groups" ]; then
                  mkdir -p "$profile/chrome"
                  [ -f "$ZEN_CONFIG/userChrome.css" ] && cp "$ZEN_CONFIG/userChrome.css" "$profile/chrome/userChrome.css"
                  [ -f "$ZEN_CONFIG/user.js" ] && cp "$ZEN_CONFIG/user.js" "$profile/user.js"
                fi
              done
            fi
          '';
        in
        "${script}";
      RemainAfterExit = true;
    };
  };
}
