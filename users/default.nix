{ user, pkgs, ... }:

{
  users.users.${user.username} = {
    isNormalUser = true;
    description = user.fullName;
    extraGroups = [ "wheel" "bluetooth" "audio" ];
    packages = with pkgs; [ tree ];
  };
}
