{
 description="hyprland";
 inputs = {
   nixpkgs.url = "nixpkgs/nixos-unstable";
   home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
   };

  };

  outputs = {nixpkgs, home-manager, ... }:{ 
   nixosConfigurations.thinkpad-hypr = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     modules = [
       ./configuration.nix
        home-manager.nixosModules.home-manager {
        home-manager = 
        {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.fabvarisco = import ./home.nix;
              backupFileExtension = "backup";
              };
         }
      ];
   };
}; 

}
