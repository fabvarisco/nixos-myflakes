{ pkgs, ... }:

{
  home.pointerCursor = {
    name = "Twilight";
    package = pkgs.stdenvNoCC.mkDerivation {
      pname = "twilight-cursor-theme";
      version = "2024.02.14";
      src = pkgs.fetchFromGitHub {
        owner = "yeyushengfan258";
        repo = "Twilight-Cursors";
        rev = "ca9c69f7632fda345d71bd6062de136d77924fe9";
        sha256 = "sha256-8HENtltZVmCybcS6o8rRQ306ZkNCCz8eF7eYaxYQgfE=";
      };
      installPhase = ''
        mkdir -p $out/share/icons/Twilight
        cp -r dist/* $out/share/icons/Twilight/
      '';
    };
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
