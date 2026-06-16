{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  networking.hostName = "beelink";
  programs.nix-ld.enable = true; 
  hardware.graphics = {
    enable = true;
    enable32Bit = true; 
    
    extraPackages = with pkgs; [
      libva-utils
      rocmPackages.clr.icd 
    ];
  };


  # Power profiles (consumed by noctalia power-profile widget; no TLP on this host)
  services.power-profiles-daemon.enable = true;

  # Steam (gaming.nix handles the rest)
  programs.steam.localNetworkGameTransfers.openFirewall = true;

  system.stateVersion = "25.05";
}
