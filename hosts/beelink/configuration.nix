{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "beelink";

  # AMD Radeon 780M (GPU integrada do Ryzen 8745HS)
  hardware.graphics.enable = true;

  # SDDM: desktop sem tela interna, detecta monitor automaticamente
  services.xserver.displayManager.setupCommands = ''
    PRIMARY=$(${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep " connected" | head -1 | cut -d' ' -f1)
    if [ -n "$PRIMARY" ]; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output "$PRIMARY" --primary --auto
    fi
  '';

  system.stateVersion = "25.05";
}
