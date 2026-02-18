{ config, pkgs, inputs, ... }:

{
 home.username = "fabvarisco";
 home.homeDirectory = "/home/fabvarisco";
 home.stateVersion = "25.05";

 home.packages = with pkgs; [
   pywal
   pywalfox-native
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
     # Use pywal-generated starship config if available
     if [ -f "$HOME/.cache/wal/starship.toml" ]; then
       export STARSHIP_CONFIG="$HOME/.cache/wal/starship.toml"
     fi
     eval "$(starship init bash)"
     fastfetch
   '';
 };

 home.file.".config/hypr".source = ./config/hypr;
 home.file.".config/wofi".source = ./config/wofi;
 home.file.".config/waybar".source = ./config/waybar;
 home.file.".config/kitty".source = ./config/kitty;
 home.file.".config/btop".source = ./config/btop;
 home.file.".config/starship.toml".source = ./config/starship.toml;
 home.file.".config/swaync".source = ./config/swaync;
 home.file.".config/zen".source = ./config/zen;
 home.file.".local/share/zen-startpage".source = ./config/zen/startpage;

 home.file.".config/kde".source = ./config/kde;



 # Wallpapers
 home.file.".config/walls".source = ./config/walls;
 home.file.".config/walls".recursive = true;
 
 # Pics
 home.file.".config/profile-pics".source = ./config/profile-pics;
 home.file.".config/profile-pics".recursive = true;

}
