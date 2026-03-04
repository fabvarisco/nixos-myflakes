{ inputs, ... }:

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
      close_on_focus_loss = true;
      pop_to_root_on_close = true;
      terminal = "kitty";
      font.normal = {
        size = 10;
        family = "JetBrains Mono Nerd Font";
      };
      launcher_window.opacity = 1.0;
    };
  };
}
