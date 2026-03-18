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

  # SilentSDDM theme
  programs.silentSDDM = {
    enable = true;
    theme = "rei";
    profileIcons = {
      "fabvarisco" = ../../config/profile-pics/profile_1.jpg;
    };
  };

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
