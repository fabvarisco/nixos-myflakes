{ pkgs, ... }:

{
  # GPU Screen Recorder - capabilities for gsr-kms-server
  security.wrappers.gsr-kms-server = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
  };

  # Steam UI scaling for HiDPI monitors
  environment.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
  };

  environment.systemPackages = with pkgs; [
    pcsx2
    gpu-screen-recorder      # Replay buffer / recording (like NVIDIA ShadowPlay)
    gpu-screen-recorder-gtk  # GUI for gpu-screen-recorder
    mangohud                  # Overlay de FPS/stats (pressione R_Shift+F12 no jogo)
    protonup-qt              # Gerenciar versões do Proton
  ];

  programs.gamemode.enable = true;

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
