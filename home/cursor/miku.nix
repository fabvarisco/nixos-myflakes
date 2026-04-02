{ pkgs, ... }:

{
  home.pointerCursor = {
    name = "miku-cursor-linux";
    package = pkgs.stdenvNoCC.mkDerivation {
      pname = "miku-cursor-theme";
      version = "2024.01.01";
      src = pkgs.fetchFromGitHub {
        owner = "supermariofps";
        repo = "hatsune-miku-windows-linux-cursors";
        rev = "main";
        sha256 = "sha256-HCHo4GwWLvjjnKWNiHb156Z+NQqliqLX1T1qNxMEMfE=";
      };
      installPhase = ''
        mkdir -p $out/share/icons/miku-cursor-linux
        cp -r miku-cursor-linux/* $out/share/icons/miku-cursor-linux/
      '';
    };
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };
}
