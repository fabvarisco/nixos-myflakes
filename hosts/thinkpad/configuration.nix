{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "nixos";

  # ThinkPad: touchpad Synaptics RMI4/Intertouch
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];
  boot.kernelModules = [ "rmi_smbus" ];

  # Touchpad
  services.libinput.touchpad = {
    tapping = true;
    naturalScrolling = false;
    middleEmulation = true;
    disableWhileTyping = true;
  };

  # Gerenciamento de energia (TLP para ThinkPad)
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

  # Fingerprint reader (opcional - aceita senha OU fingerprint)
  services.fprintd.enable = true;

  # Configuração PAM para fingerprint opcional com timeout
  security.pam.services.sddm = {
    fprintAuth = true;
    rules.auth.fprintd.control = "sufficient";
  };
  security.pam.services.sudo = {
    fprintAuth = true;
    rules.auth.fprintd.control = "sufficient";
  };
  security.pam.services.hyprlock = {
    fprintAuth = true;
    rules.auth.fprintd.control = "sufficient";
  };

  # SDDM
  services.xserver.displayManager.setupCommands = ''
    EXTERNAL=$(${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep " connected" | ${pkgs.gnugrep}/bin/grep -v "eDP" | head -1 | cut -d' ' -f1)
    if [ -n "$EXTERNAL" ]; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output "$EXTERNAL" --primary --auto --output eDP-1 --auto
    fi
  '';

  environment.systemPackages = with pkgs; [
    fprintd
    cheese  # Webcam app
  ];

  system.stateVersion = "25.05";
}
