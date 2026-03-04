{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pcsx2
    steam
  ];
}
