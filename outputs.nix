{ self, nixpkgs, home-manager, silent-sddm, vicinae, ... } @inputs:

let
  homeManagerModules = [
    silent-sddm.nixosModules.default
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.fabvarisco = import ./users/fabvarisco/home.nix;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; };
      };
    }
  ];
in {
  nixosConfigurations.thinkpad-hypr = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/thinkpad/configuration.nix ] ++ homeManagerModules;
  };

  nixosConfigurations.beelink-hypr = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/beelink/configuration.nix ] ++ homeManagerModules;
  };
}
