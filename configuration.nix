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

  # Enable networking with iwd
  networking.wireless.iwd.enable = true;

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

  users.users.fabvarisco = {
    isNormalUser = true;
    description = "Fabricio Varisco Oliveira";
    extraGroups = [ "wheel" "bluetooth" "audio" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Hyprland
  programs.hyprland = {
     enable = true;
     xwayland.enable = true;
  };

  # SDDM Display Manager with SilentSDDM theme
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # SilentSDDM theme configuration
  programs.silentSDDM = {
    enable = true;
    theme = "default";  # Opções: default, rei, ken, silvia, everforest, catppuccin, nord
  };

  # Enable sound with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # GTK Dark Mode
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
        };
      };
    }];
  };

  # Firefox
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    waybar
    wofi
    kitty
    hyprpaper
    hyprlock
    starship
    fastfetch
    nautilus
    vscode
    gh    
    nodejs_24
    claude-code

    # Browsers
  

    # Social
    discord


    #--- UI ---
    
    swww
    
    # Network
    impala           # TUI WiFi manager
    nwg-look
    nwg-displays    # Monitor/display configuration GUI
    nwg-dock-hyprland  # Dock for Hyprland

    # Notifications
    swaynotificationcenter  # Notification daemon and center
    libnotify               # notify-send command

    # Qt theming (dark mode for Dolphin, etc)
    kdePackages.breeze
    kdePackages.breeze-icons

    # Audio
    pavucontrol      # GUI audio control
    pamixer          # CLI audio control
    playerctl        # Media player control

    # Bluetooth
    blueman          # Bluetooth manager GUI
    
    # Brightness control
    brightnessctl    # CLI brightness control
    
    # OSD (On-Screen Display)
    avizo            # Visual feedback for volume/brightness
     
    #--- Utilities ---
    yazi             # Terminal file manager
    btop             # System monitor

    # Media viewers
    imv              # Image viewer (Wayland)
    mpv              # Video player
    vlc              # Alternative video player
    
    # Screenshot tools
    grim             # Screenshot utility (Wayland)
    slurp            # Screen region selector
    swappy           # Screenshot editor
    wl-clipboard     # Clipboard utilities (wl-copy, wl-paste)
    clipse           # Clipboard manager with TUI
    imagemagick      # Image manipulation (for clipboard thumbnails)

    # Calendar
    gnome-calendar        # Calendar app
    gnome-online-accounts # Sync with Google, Microsoft, etc
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];   

  system.stateVersion = "25.05";

}
