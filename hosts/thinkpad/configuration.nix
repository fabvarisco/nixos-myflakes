{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "thinkpad";
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

  # ThinkPad
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  #: touchpad Synaptics RMI4/Intertouch — lid_init_state prevents inconsistent suspend on close
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" "button.lid_init_state=open" ];
  boot.kernelModules = [ "rmi_smbus" ];

  # Touchpad settings
  services.libinput.touchpad = {
    tapping = true;
    naturalScrolling = false;
    middleEmulation = true;
    disableWhileTyping = true;
  };

  # Power management (TLP for ThinkPad)
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = 1;
    };
  };
  services.power-profiles-daemon.enable = false;

  # Thermal management — complements TLP for mixed workloads on ThinkPads
  services.thermald.enable = true;

  # Delegate lid switch to Hyprland; prevents unexpected suspend before compositor starts
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    powerKey = "poweroff";
  };

  # Fingerprint reader — accepts password OR fingerprint
  services.fprintd.enable = true;

  # PAM integration for fingerprint auth
  security.pam.services.sddm.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.hyprlock.fprintAuth = true;


  environment.systemPackages = with pkgs; [
    fprintd
    cheese  # Webcam app
  ];

  system.stateVersion = "25.05";
}
