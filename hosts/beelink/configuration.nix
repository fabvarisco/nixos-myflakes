{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "beelink";

  # AMD Radeon 780M (GPU Ryzen 8745HS)
  hardware.graphics.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
    localNetworkGameTransfers.openFirewall = true;
  };

  system.stateVersion = "25.05";
}
