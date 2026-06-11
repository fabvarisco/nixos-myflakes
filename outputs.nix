{ self, nixpkgs, silentSDDM, home-manager, ... } @inputs:

let
  mkHost = { hostname, desktop, extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/desktop/${desktop}.nix
        silentSDDM.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = { inherit inputs self; };
            users.fabvarisco = import ./users/fabvarisco/home.nix;
          };
        }
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
