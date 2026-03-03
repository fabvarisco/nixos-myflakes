# PLACEHOLDER - Este arquivo precisa ser gerado diretamente no Beelink SER8.
#
# Passos:
#   1. Boot pelo ISO do NixOS no Beelink
#   2. Execute: nixos-generate-config --show-hardware-config
#   3. Substitua este arquivo pelo output gerado
#
# Alternativamente, após instalar o NixOS:
#   sudo nixos-generate-config --root /mnt
#   cat /mnt/etc/nixos/hardware-configuration.nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Beelink SER8 - AMD Ryzen 7 8745HS + Radeon 780M
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # SUBSTITUIR pelos UUIDs reais (obter com: lsblk -f)
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/SUBSTITUIR-UUID-ROOT";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/SUBSTITUIR-UUID-BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
