{ config, lib, pkgs, inputs, ... }:

{
  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # SDDM for Hyprland (X11 greeter for better compatibility)
  services.displayManager.sddm.wayland.enable = lib.mkForce false;

  # Wayland tools (screenshot, clipboard)
  environment.systemPackages = with pkgs; [
    # Screenshot
    grim
    slurp
    swappy

    # Clipboard
    wl-clipboard
    clipse
    imagemagick
  ];
}
