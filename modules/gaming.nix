{ pkgs, ... }:

{
  # GPU Screen Recorder capabilities
  security.wrappers.gsr-kms-server = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
  };

  # vm.max_map_count: evita crashes em jogos com uso intenso de memória virtual
  # (CS2, Hogwarts Legacy, etc.) — Valve recomenda >= 2147483642 no Steam Runtime.
  # vm.swappiness=10: reduz pressão de swap durante o jogo, mantém RAM para o jogo.
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "vm.swappiness" = 10;
  };

  environment.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
    PROTON_ENABLE_NVAPI = "0";      # desativa shim NVIDIA API no AMD (reduz overhead)
    PROTON_NO_ESYNC = "0";          # mantém esync LIGADO (nome invertido: 0 = não desativar)
    DXVK_ASYNC = "1";               # pipeline async: elimina stutters na primeira carga de shaders
    VKD3D_CONFIG = "no_upload_hvv"; # evita uploads VRAM desnecessários no AMD para DX12
    WINE_FULLSCREEN_FSR = "1";      # FSR upscaling no Proton/Wine em fullscreen
  };

  environment.systemPackages = with pkgs; [
    pcsx2
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    mangohud
    protonup-qt
    heroic      # Epic Games + GOG
    wine
    winetricks
  ];

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;             # reduz nice value do jogo em 10 (maior prioridade CPU)
        ioprio = 0;              # prioridade I/O real-time
        inhibit_screensaver = 1; # impede screensaver/lock durante gameplay
      };
      gpu = {
        # "accept-responsibility" é o valor literal esperado pelo gamemode
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
