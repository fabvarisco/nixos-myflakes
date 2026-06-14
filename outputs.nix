{ self, nixpkgs, home-manager, vicinae, silentSDDM, ... } @inputs:

let
  mkHost = { hostname, desktop, extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/desktop/${desktop}.nix
        silentSDDM.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.fabvarisco = { ... }: {
              imports = [
                ./home/common.nix
                ./home/${desktop}.nix
                ./home/cursor/miku.nix
              ];
              home.username = "fabvarisco";
              home.homeDirectory = "/home/fabvarisco";
              home.stateVersion = "25.05";
            };
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
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
