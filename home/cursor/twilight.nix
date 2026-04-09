{ pkgs, ... }:

{
  home.pointerCursor = {
    name = "Twilight-cursors";
    package = pkgs.stdenvNoCC.mkDerivation {
      pname = "twilight-cursor-theme";
      version = "2024.01.01";
      src = pkgs.fetchFromGitHub {
        owner = "yeyushengfan258";
        repo = "Twilight-Cursors";
        rev = "main";
        sha256 = "sha256-8HENtltZVmCybcS6o8rRQ306ZkNCCz8eF7eYaxYQgfE=";
      };
      installPhase = ''
        mkdir -p $out/share/icons/Twilight-cursors
        cp -r dist/* $out/share/icons/Twilight-cursors/
      '';
    };
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };
}
