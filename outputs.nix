{ self, nixpkgs, silentSDDM, ... } @inputs:

let
  mkHost = { hostname, desktop, extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/desktop/${desktop}.nix
        silentSDDM.nixosModules.default
      ] ++ extraModules;
    };
in {
  nixosConfigurations = {
    thinkpad-hypr = mkHost {
      hostname = "thinkpad";
      desktop = "hyprland";
    };
    beelink-hypr = mkHost {
      hostname = "beelink";
      desktop = "hyprland";
    };
  };
}
