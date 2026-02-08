{ config, pkgs, ... }: 

{
 home.username = "fabvarisco";
 home.homeDirectory = "/home/fabvarisco";
 home.stateVersion = "25.05";
 programs.bash = {
 enable = true;
 initExtra = '' eval "$(starship init bash)"'';
 shellAliases = {
   home = "fabvarisco";
  };
 };


 home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/my-dotfiles/config/hypr";
 home.file.".config/wofi".source = ./config/wofi;
 home.file.".config/waybar".source = ./config/waybar;
 home.file.".config/kitty".source = ./config/kitty;
 home.file.".config/starship.toml".source = ./config/starship.toml;
 home.file.".config/swaync".source = ./config/swaync;
 
 # Wallpapers
 home.file.".config/walls".source = ./config/walls;
 home.file.".config/walls".recursive = true;


}
