{ pkgs, ... }:

{
  users.users.fabvarisco = {
    isNormalUser = true;
    description = "Fabricio Varisco Oliveira";
    extraGroups = [ "wheel" "bluetooth" "audio" ];
    packages = with pkgs; [ tree ];
  };
}
