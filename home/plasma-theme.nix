{ config, pkgs, lib, ... }:

let
  moeDarkTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "moe-dark-kde-theme";
    version = "2024.05";

    src = pkgs.fetchFromGitLab {
      owner = "jomada";
      repo = "moe-dark";
      rev = "main";
      hash = lib.fakeHash;  # Build once to get the correct hash
    };

    installPhase = ''
      runHook preInstall

      # Global theme (look and feel)
      if [ -d "look-and-feel" ]; then
        mkdir -p $out/share/plasma/look-and-feel
        cp -r look-and-feel/* $out/share/plasma/look-and-feel/
      fi

      # Plasma style (desktop theme)
      if [ -d "plasma" ]; then
        mkdir -p $out/share/plasma/desktoptheme
        cp -r plasma/* $out/share/plasma/desktoptheme/
      fi

      # Color schemes
      if [ -d "color-schemes" ]; then
        mkdir -p $out/share/color-schemes
        cp -r color-schemes/* $out/share/color-schemes/
      fi

      # Aurorae (window decorations)
      if [ -d "aurorae" ]; then
        mkdir -p $out/share/aurorae/themes
        cp -r aurorae/* $out/share/aurorae/themes/
      fi

      # Kvantum theme
      if [ -d "kvantum" ]; then
        mkdir -p $out/share/Kvantum
        cp -r kvantum/* $out/share/Kvantum/
      fi

      # Konsole color scheme
      if [ -d "konsole" ]; then
        mkdir -p $out/share/konsole
        cp -r konsole/* $out/share/konsole/
      fi

      # SDDM theme
      if [ -d "sddm" ]; then
        mkdir -p $out/share/sddm/themes
        cp -r sddm/* $out/share/sddm/themes/
      fi

      runHook postInstall
    '';

    meta = with lib; {
      description = "Moe Dark - Dark theme with blur transparencies and red tones";
      homepage = "https://gitlab.com/jomada/moe-dark";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };

  # Wallpapers from theme (copied to ~/.config/walls)
  moeDarkWallpapers = pkgs.stdenvNoCC.mkDerivation {
    pname = "moe-dark-wallpapers";
    version = "2024.05";

    src = pkgs.fetchFromGitLab {
      owner = "jomada";
      repo = "moe-dark";
      rev = "main";
      hash = lib.fakeHash;
    };

    installPhase = ''
      runHook preInstall
      if [ -d "wallpapers" ]; then
        mkdir -p $out
        cp -r wallpapers/* $out/
      fi
      runHook postInstall
    '';
  };
in
{
  home.packages = [ moeDarkTheme ];

  # Link wallpapers to ~/.config/walls/moe-dark/
  home.file.".config/walls/moe-dark" = {
    source = moeDarkWallpapers;
    recursive = true;
  };

  # Optional: Set as default theme in kdeglobals
  # home.file.".config/kdeglobals".text = lib.mkAfter ''
  #   [KDE]
  #   LookAndFeelPackage=moe-dark
  # '';
}
