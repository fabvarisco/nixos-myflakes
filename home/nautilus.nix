{ config, lib, pkgs, ... }:

{
  # GTK theme e configurações
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.bookmarks = [
      "file:///home/fabvarisco/Downloads Downloads"
      "file:///home/fabvarisco/Developer Developer"
      "file:///home/fabvarisco/Documents Documents"
    ];
  };

  # Preferências do Nautilus via dconf
  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = true;
      default-sort-order = "name";
      default-sort-in-reverse-order = false;
      show-delete-permanently = true;
    };

    "org/gnome/nautilus/list-view" = {
      default-column-order = ["name" "size" "type" "date_modified"];
      default-visible-columns = ["name" "size" "date_modified"];
      use-tree-view = false;
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = lib.gvariant.mkTuple [(lib.gvariant.mkInt32 1200) (lib.gvariant.mkInt32 700)];
      maximized = false;
      sidebar-width = lib.gvariant.mkInt32 200;
    };

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "small";
    };
  };
}
