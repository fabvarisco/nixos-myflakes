{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Compilers
    gcc
    clang

    # Build systems
    cmake
    gnumake
    ninja
    meson

    # Debugger
    gdb

    # Dynamic analysis / memory error detection
    valgrind

    # Clang toolchain: clangd (LSP), clang-format, clang-tidy
    clang-tools

    # Library discovery for build systems
    pkg-config
  ];
}
