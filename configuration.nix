{ config, pkgs, lib, inputs, ... }:

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

  # Power Management (TLP for ThinkPad)
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # CPU turbo boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Platform profile (performance, balanced, low-power)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # ThinkPad Battery Thresholds (preserve battery health)
      # Start charging when below 75%, stop at 80%
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # Runtime PM for PCI devices
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # USB autosuspend
      USB_AUTOSUSPEND = 1;
    };
  };

  # Disable power-profiles-daemon (conflicts with TLP)
  services.power-profiles-daemon.enable = false;

  # Hyprland
  programs.hyprland = {
     enable = true;
     xwayland.enable = true;
  };

  # Enable X11 for SDDM
  services.xserver.enable = true;

  # SDDM Display Manager with SilentSDDM theme
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = lib.mkForce false; # SDDM X11 para configurar monitores
  };

  # SDDM setup commands to configure external monitor on login
  services.xserver.displayManager.setupCommands = ''
    EXTERNAL=$(${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep " connected" | ${pkgs.gnugrep}/bin/grep -v "eDP" | head -1 | cut -d' ' -f1)
    if [ -n "$EXTERNAL" ]; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output "$EXTERNAL" --primary --auto --output eDP-1 --auto
    fi
  '';

  # SilentSDDM theme configuration
  programs.silentSDDM = {
    enable = true;
    theme = "rei";
    backgrounds = {
      "LoginScreen" = ./config/sddm-theme/backgrounds/rei.mp4;
      "LockScreen" = ./config/sddm-theme/backgrounds/rei.mp4;
    };
    profileIcons = {
      "fabvarisco" = ./config/profile-pics/miku.jpg;
    };
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
    kitty
    hyprpaper
    hyprlock
    hypridle
    starship
    fastfetch
    nautilus
    vscode
    gh    
    nodejs_24
    claude-code
    
    # Browsers
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    
    # Social
    discord


    #--- UI ---

    swww
    wlogout
    
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

    # GTK icons (required for MPRIS media player icons in swaync)
    adwaita-icon-theme

    # Audio
    wiremix
    pwvucontrol      # GUI audio control (PipeWire)
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
    unzip            # Extract zip files
    zip              # Create zip files
    p7zip            # 7z support
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
