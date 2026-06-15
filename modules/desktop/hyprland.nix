{ config, lib, pkgs, inputs, ... }:

{
  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # nixpkgs' programs.hyprland wraps Hyprland with cap_sys_nice+ep so it can set
  # SCHED_RR; Hyprland then raises it into the AMBIENT set, which leaks to every
  # child and breaks bwrap-sandboxed apps (Steam pressure-vessel, Flatpak). Drop
  # the cap — ananicy/gamemode already handle scheduling priority.
  security.wrappers.Hyprland.capabilities = lib.mkForce "";

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
