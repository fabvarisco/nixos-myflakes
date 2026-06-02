{ pkgs, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = [ "gnome" ];
  };

  # Wallpaper slideshow user service
  systemd.user.services.wallpaper-slideshow = {
    description = "Automatic wallpaper slideshow (changes every 12h)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "%h/.config/niri/wallpaper-slideshow.sh";
      Restart = "on-failure";
      RestartSec = "10";
    };
  };

  # Dconf settings for Nautilus (previously managed by home-manager)
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        show-hidden-files = true;
        default-sort-order = "name";
        default-sort-in-reverse-order = false;
        show-delete-permanently = true;
      };
      "org/gnome/nautilus/list-view" = {
        default-column-order = [ "name" "size" "type" "date_modified" ];
        default-visible-columns = [ "name" "size" "date_modified" ];
        use-tree-view = false;
      };
    };
  }];
}
