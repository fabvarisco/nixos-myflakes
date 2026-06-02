{ self, nixpkgs, silentSDDM, wrapper-modules, ... } @inputs:

let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};

  myNoctalia = wrapper-modules.wrappers.noctalia-shell.wrap {
    inherit pkgs;
    settings = builtins.fromJSON (builtins.readFile ./config/noctalia/settings.json);
  };

  mkHost = { hostname, desktop, extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs myNoctalia; };
      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/desktop/${desktop}.nix
        silentSDDM.nixosModules.default
      ] ++ extraModules;
    };
in {
  nixosConfigurations = {
    thinkpad-niri = mkHost {
      hostname = "thinkpad";
      desktop = "niri";
    };
    beelink-niri = mkHost {
      hostname = "beelink";
      desktop = "niri";
    };
  };
}
