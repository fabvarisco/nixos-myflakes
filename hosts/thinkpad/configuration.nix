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
      libva-vdpau-driver
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

  # Power management — power-profiles-daemon drives CPU governor, EPP,
  # boost and platform_profile in response to powerprofilesctl set ...
  services.power-profiles-daemon.enable = true;

  # Charge thresholds (PPD doesn't manage these). Bound to the BAT0 udev
  # device so it applies once the battery enumerates at boot/resume.
  systemd.services.thinkpad-charge-thresholds = {
    description = "Set ThinkPad BAT0 charge thresholds (75/80)";
    wantedBy = [ "multi-user.target" ];
    after = [ "sys-class-power_supply-BAT0.device" ];
    bindsTo = [ "sys-class-power_supply-BAT0.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
  };

  services.thermald.enable = true;

  # Delegate lid switch to Hyprland; prevents unexpected suspend before compositor starts
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandlePowerKey = "poweroff";
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
