{ pkgs, self, inputs, ... }:

{
  home.username = "fabvarisco";
  home.homeDirectory = "/home/fabvarisco";
  home.stateVersion = "25.05";

  # home-manager tracks master (26.11) while nixpkgs follows nixos-unstable (currently 26.05).
  # The combination is intentional; silence the release-mismatch warning.
  home.enableNixpkgsReleaseCheck = false;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      bash ${self}/config/shared/fastfetch/random-logo.sh
    '';
  };

  programs.starship.enable = true;

  xdg.configFile = {
    "kitty".source         = ../../config/shared/kitty;
    "hypr".source          = ../../config/hyprland;
    "btop".source          = ../../config/shared/btop;
    "starship.toml".source = ../../config/shared/starship.toml;
    "fastfetch".source     = ../../config/shared/fastfetch;
    "walls".source         = ../../config/walls;
    "profile-pics".source  = ../../config/profile-pics;
    "zen/userChrome.css".source = ../../config/zen/userChrome.css;
    "zen/user.js".source        = ../../config/zen/user.js;
  };

  home.file = {
    ".claude/agents".source = ../../config/claude/agents;
    ".claude/skills".source = ../../config/claude/skills;
    ".local/share/zen-startpage".source = ../../config/zen/startpage;
  };
}
