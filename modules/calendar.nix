{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-calendar
    gnome-online-accounts
    calcure
  ];
}
