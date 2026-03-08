{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    gh
    vscode
    nodejs_24
    claude-code
    fastfetch
    kitty
    starship
    godotPackages_4_5.godot
    neovim
  ];
}
