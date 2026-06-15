{ inputs, pkgs, ... }:

let
  mkExt = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.mkVicinaeExtension;
  extsSrc = inputs.vicinae-extensions;
  ext = name: mkExt {
    pname = name;
    version = "0-unstable-${extsSrc.shortRev or "unknown"}";
    src = "${extsSrc}/extensions/${name}";
  };
  localExt = name: mkExt {
    pname = name;
    version = "0-local";
    src = ../vicinae-extensions/${name};
  };
in
{
  imports = [ inputs.vicinae.homeManagerModules.default ];

  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = "1";
      };
    };
    settings = {
      close_on_focus_loss = false;
      pop_to_root_on_close = true;
      terminal = "kitty";
      font.normal = {
        size = 10;
        family = "JetBrains Mono Nerd Font";
      };
      launcher_window.opacity = 1.0;
    };
    extensions = [
      (ext "hypr")
      (ext "nix")
      (ext "process-manager")
      (localExt "noctalia-settings")
    ];
  };
}
