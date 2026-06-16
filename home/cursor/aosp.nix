{ pkgs, ... }:

{
  home.pointerCursor = {
    name = "AOSP Cursors";
    package = pkgs.stdenvNoCC.mkDerivation {
      pname = "aosp-cursors";
      version = "1.3.0";
      src = pkgs.fetchurl {
        url = "https://github.com/Tech-Tac/aosp-cursors/releases/download/1.3.0/aosp-cursors-linux-1.3.0.tar.xz";
        sha256 = "sha256-1vCDu7U2crsWEAZoMRPUZ1bRGmDcQvI3ZqnV4dzY5Aw=";
      };
      sourceRoot = "aosp-cursors";
      installPhase = ''
        mkdir -p "$out/share/icons/AOSP Cursors"
        cp -r cursors cursors_scalable index.theme "$out/share/icons/AOSP Cursors/"
      '';
    };
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
