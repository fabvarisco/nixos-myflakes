{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ../config/hyprland/ags;

    extraPackages = with inputs.astal.packages.${pkgs.system}; [
      astal3
      io
      battery
      wireplumber
      network
      bluetooth
      powerprofiles
      hyprland
      apps
      tray
      notifd
      mpris
      auth
    ];
  };

  home.packages = with pkgs; [
    bun
    dart-sass
    wayshot
    wf-recorder
    hyprpicker
    wl-clipboard
    brightnessctl
    gtk3
    accountsservice
    inputs.matugen.packages.${pkgs.system}.default
  ];
}
