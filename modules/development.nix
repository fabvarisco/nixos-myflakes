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
    fd
    ripgrep
    gcc
    deno
    # LSPs e ferramentas para neovim
    tree-sitter
    typescript-language-server
    vue-language-server
    lua-language-server
    nixd
    clang-tools
    android-tools
    code-cursor
    inputs.herdr.packages.${pkgs.system}.default
  ];
}
