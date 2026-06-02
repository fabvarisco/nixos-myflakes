{ self, nixpkgs, silentSDDM, ... } @inputs:

let
  mkHost = { hostname, desktop, extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
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
