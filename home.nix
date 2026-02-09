{ config, pkgs, inputs, ... }:

{
 home.username = "fabvarisco";
 home.homeDirectory = "/home/fabvarisco";
 home.stateVersion = "25.05";

 # Cursor Twilight
 home.pointerCursor = {
   name = "Twilight";
   package = pkgs.stdenvNoCC.mkDerivation {
     pname = "twilight-cursor-theme";
     version = "2024.02.14";
     src = pkgs.fetchFromGitHub {
       owner = "yeyushengfan258";
       repo = "Twilight-Cursors";
       rev = "5d8cd90b57e70b9435d78f4c6aa24dfe549f6d00";
       sha256 = "sha256-WjjSVQL0oM1sEMVnf7D3mn2S1AJO3Fq5jRYcKLGv3XY=";
     };
     installPhase = ''
       mkdir -p $out/share/icons
       cp -r dist/Twilight $out/share/icons/
     '';
   };
   size = 24;
   gtk.enable = true;
   x11.enable = true;
 };

 programs.bash = {
   enable = true;
   initExtra = ''
     eval "$(starship init bash)"
     fastfetch
   '';
 };

 home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/my-dotfiles/config/hypr";
 home.file.".config/wofi".source = ./config/wofi;
 home.file.".config/waybar".source = ./config/waybar;
 home.file.".config/kitty".source = ./config/kitty;
 home.file.".config/starship.toml".source = ./config/starship.toml;
 home.file.".config/swaync".source = ./config/swaync;

 # SDDM theme - arquivos estáticos
 home.file.".config/sddm-theme/Main.qml".source = ./config/sddm-theme/Main.qml;
 home.file.".config/sddm-theme/metadata.desktop".source = ./config/sddm-theme/metadata.desktop;

 # SDDM theme - config gerado dinamicamente com paths do usuário
 home.file.".config/sddm-theme/theme.conf".text = ''
   [General]
   Background=${config.home.homeDirectory}/.config/walls/lock.jpg
   Avatar=${config.home.homeDirectory}/.config/profile-pics/miku.jpg
   AccentColor=#cdd6f4
   BackgroundColor=#1e1e2e
   ForegroundColor=#cdd6f4
   Font=JetBrainsMono Nerd Font
   FontSize=12
   RoundCorners=8
 '';

 home.file.".config/kde".source = ./config/kde;



 # Wallpapers
 home.file.".config/walls".source = ./config/walls;
 home.file.".config/walls".recursive = true;
 
 # Pics
 home.file.".config/profile-pics".source = ./config/profile-pics;
 home.file.".config/profile-pics".recursive = true;

}
