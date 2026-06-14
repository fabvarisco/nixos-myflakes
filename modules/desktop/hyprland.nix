{ config, lib, pkgs, inputs, ... }:

{
  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # XDG Portal for Hyprland (screen sharing, file dialogs, app communication)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  # SDDM with SilentSDDM theme (configured in common.nix)

  # Wayland tools (screenshot, clipboard)
  environment.systemPackages = with pkgs; [
    # Screenshot
    grim
    slurp
    swappy

    # Clipboard
    wl-clipboard
    imagemagick
  ];
}
