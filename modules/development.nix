{ pkgs, self, ... }:

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
    godot_4-mono
    neovim
    github-desktop

  ];

  programs.bash.interactiveShellInit = ''
    ${self}/config/shared/fastfetch/random-logo.sh
    eval "$(starship init bash)"
  '';
}
