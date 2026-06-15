{ user, pkgs, ... }:

{
  users.users.${user.username} = {
    isNormalUser = true;
    description = user.fullName;
    extraGroups = [ "wheel" "bluetooth" "audio" "networkmanager" "video" ];
    packages = with pkgs; [ tree ];
  };
}
