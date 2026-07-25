{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    gh
    vscode
    nodejs_24
    ionic-cli
    claude-code
    fastfetch
    kitty
    starship
    godotPackages_4_5.godot
    godot_4-mono
    neovim
    android-tools
    code-cursor
    inputs.herdr.packages.${pkgs.system}.default
  ];
}
