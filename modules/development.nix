{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    gh
    (vscode.override { commandLineArgs = "--password-store=gnome-libsecret"; })
    nodejs_24
    claude-code
    fastfetch
    kitty
    starship
    godotPackages_4_5.godot
    godot_4-mono
    neovim
    github-desktop
  ];
}
