{
 description="hyprland";
 inputs = {
   nixpkgs.url = "nixpkgs/nixos-unstable";
   home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
   };
   silent-sddm = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
   };
   zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
   vicinae = {
      url = "github:vicinaehq/vicinae";
    };
  };

  outputs = {nixpkgs, home-manager, silent-sddm, vicinae, ... }@inputs:{
   nixosConfigurations.thinkpad-hypr = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     specialArgs = { inherit inputs; };
     modules = [
       ./configuration.nix
       silent-sddm.nixosModules.default
        home-manager.nixosModules.home-manager {
        home-manager =
        {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.fabvarisco = import ./home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs; };
              };
         }
      ];
   };
}; 

}
