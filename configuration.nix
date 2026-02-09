{ config, pkgs, ... }:

let
  # Wallpaper para o tema SDDM
  sddmWallpaper = ./config/walls/lock.jpg;

  # Tema SDDM customizado
  sddm-nixos-theme = pkgs.stdenv.mkDerivation {
    name = "sddm-nixos-linux-theme";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/nixos-linux

      # Copiar wallpaper para o tema
      cp ${sddmWallpaper} $out/share/sddm/themes/nixos-linux/background.jpg

      cat > $out/share/sddm/themes/nixos-linux/metadata.desktop << 'METADATA'
[SddmGreeterTheme]
Name=NixOS Linux
Description=Clean login theme with Linux branding
Author=fabvarisco
Version=1.0
Type=sddm-theme
MainScript=Main.qml
ConfigFile=theme.conf
METADATA

      cat > $out/share/sddm/themes/nixos-linux/theme.conf << 'THEMECONF'
[General]
Background=background.jpg
AccentColor=#cdd6f4
BackgroundColor=#1e1e2e
ForegroundColor=#cdd6f4
Font=JetBrainsMono Nerd Font
FontSize=12
RoundCorners=8
THEMECONF

      cat > $out/share/sddm/themes/nixos-linux/Main.qml << 'MAINQML'
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height

    property string accentColor: "#cdd6f4"
    property string backgroundColor: "#1e1e2e"
    property string foregroundColor: "#cdd6f4"
    property string errorColor: "#f38ba8"
    property string successColor: "#a6e3a1"

    Connections {
        target: sddm
        function onLoginSucceeded() { errorMessage.text = "" }
        function onLoginFailed() {
            errorMessage.text = "Login failed. Please try again."
            passwordField.text = ""
            passwordField.focus = true
        }
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    FastBlur {
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: 50
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: avatarContainer
            width: 120
            height: 120
            radius: 60
            color: backgroundColor
            border.color: accentColor
            border.width: 3
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.25

            Text {
                anchors.centerIn: parent
                text: "\uf007"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 48
                color: accentColor
            }
        }

        Text {
            id: usernameLabel
            text: userModel.lastUser || "User"
            color: foregroundColor
            font.pixelSize: 24
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: avatarContainer.bottom
            anchors.topMargin: 20
        }

        Rectangle {
            id: loginContainer
            width: 320
            height: 50
            radius: 8
            color: backgroundColor
            border.color: passwordField.focus ? accentColor : Qt.darker(accentColor, 1.5)
            border.width: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: usernameLabel.bottom
            anchors.topMargin: 30

            TextField {
                id: passwordField
                anchors.fill: parent
                anchors.margins: 5
                placeholderText: "Password..."
                placeholderTextColor: Qt.darker(foregroundColor, 1.5)
                echoMode: TextInput.Password
                color: foregroundColor
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                background: Rectangle { color: "transparent" }
                Keys.onReturnPressed: sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
            }
        }

        Rectangle {
            id: loginButton
            width: 100
            height: 40
            radius: 8
            color: mouseArea.containsMouse ? Qt.lighter(accentColor, 1.1) : accentColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: loginContainer.bottom
            anchors.topMargin: 20

            Text {
                anchors.centerIn: parent
                text: "Login"
                color: backgroundColor
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
            }
        }

        Text {
            id: errorMessage
            text: ""
            color: errorColor
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: loginButton.bottom
            anchors.topMargin: 15
            visible: text !== ""
        }

        ComboBox {
            id: sessionSelector
            width: 150
            height: 30
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 30
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            textRole: "name"
            background: Rectangle { color: backgroundColor; radius: 5; opacity: 0.8 }
            contentItem: Text {
                text: sessionSelector.displayText
                color: foregroundColor
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            spacing: 8

            Text {
                id: linuxLogo
                text: "\uf17c"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 48
                color: foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.9
            }

            Text {
                text: "NixOS"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                font.bold: true
                color: foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.8
            }
        }

        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 30
            spacing: 15

            Rectangle {
                width: 40; height: 40; radius: 20
                color: rebootMouse.containsMouse ? Qt.lighter(backgroundColor, 1.3) : backgroundColor
                opacity: 0.8
                Text { anchors.centerIn: parent; text: "\uf021"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: foregroundColor }
                MouseArea { id: rebootMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sddm.reboot() }
            }

            Rectangle {
                width: 40; height: 40; radius: 20
                color: shutdownMouse.containsMouse ? Qt.lighter(backgroundColor, 1.3) : backgroundColor
                opacity: 0.8
                Text { anchors.centerIn: parent; text: "\uf011"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: foregroundColor }
                MouseArea { id: shutdownMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sddm.powerOff() }
            }
        }

        Text {
            id: clock
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 30
            color: foregroundColor
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
            opacity: 0.8
            Timer {
                interval: 1000; running: true; repeat: true; triggeredOnStart: true
                onTriggered: { var date = new Date(); clock.text = Qt.formatDateTime(date, "ddd, dd MMM yyyy  HH:mm") }
            }
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
MAINQML
    '';
  };
in
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fabvarisco = {
    isNormalUser = true;
    description = "Fabricio Varisco Oliveira";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Hyprland
  programs.hyprland = {
     enable = true;
     xwayland.enable = true;
  };

  # SDDM Display Manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "nixos-linux";
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs.kdePackages; [
      qt5compat
      qtsvg
      qtdeclarative
      qtquickcontrols2
    ];
    settings = {
      Theme = {
        CursorTheme = "macOS";
        CursorSize = 24;
      };
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

  environment.systemPackages = [
    # SDDM theme
    sddm-nixos-theme
  ] ++ (with pkgs; [
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

    # Qt theming (dark mode for Dolphin, etc)
    kdePackages.breeze
    kdePackages.breeze-icons

    # Audio
    pavucontrol      # GUI audio control
    pamixer          # CLI audio control
    playerctl        # Media player control
    
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
  ]);

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];   

  system.stateVersion = "25.05";

}
