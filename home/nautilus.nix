{ config, lib, pkgs, ... }:

{
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
      initial-size = lib.gvariant.mkTuple [1200 700];
      maximized = false;
      sidebar-width = 200;
    };

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "small";
    };
  };

  # Bookmarks para sidebar
  gtk.gtk3.bookmarks = [
    "file:///home/fabvarisco/Downloads Downloads"
    "file:///home/fabvarisco/Developer Developer"
    "file:///home/fabvarisco Home"
  ];
}
