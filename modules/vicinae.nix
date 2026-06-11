{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.services.vicinae-launcher;
  system = pkgs.stdenv.hostPlatform.system;
  pkg = inputs.vicinae.packages.${system}.default;
  jsonFormat = pkgs.formats.json { };
in {
  options.services.vicinae-launcher = {
    enable = lib.mkEnableOption "Vicinae launcher";

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkg ];

    home-manager.users.fabvarisco = {
      xdg.configFile = lib.mkIf (cfg.settings != {}) {
        "vicinae/nix.json".source =
          jsonFormat.generate "vicinae-settings.json" cfg.settings;
      };

      home.file = lib.listToAttrs (map (ext: {
        name  = ".local/share/vicinae/extensions/${ext.pname}";
        value.source = ext;
      }) cfg.extensions);
    };

    systemd.user.services.vicinae = {
      description = "Vicinae launcher/switcher";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      environment.USE_LAYER_SHELL = "1";
      serviceConfig = {
        ExecStart = "${pkg}/bin/vicinae";
        Restart = "on-failure";
      };
    };
  };
}
