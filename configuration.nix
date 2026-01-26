{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "thinkpad";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fabvarisco = {
    isNormalUser = true;
    description = "Fabricio Varisco Oliveira";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Hyprland
  programs.hyprland = {
     enable = true;
     xwayland.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Firefox
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    waybar
    wofi
    kitty
    hyprpaper
    starship
    nautilus
    
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];   

  system.stateVersion = "25.05";

}
