{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Desbloqueia todos os power play features do amdgpu (necessário para o GameMode
  # escrever amd_performance_level=high via DPM)
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  networking.hostName = "beelink";
  programs.nix-ld.enable = true; 
  hardware.graphics = {
    enable = true;
    enable32Bit = true; 
    
    extraPackages = with pkgs; [
      libva-utils
      vaapiVdpau
      libvdpau-va-gl
      rocmPackages.clr.icd
    ];
  };


  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
    localNetworkGameTransfers.openFirewall = true;
  };

  system.stateVersion = "25.05";
}
