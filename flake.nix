{
  description = "Default Nix flake config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    default.url = "github:fabvarisco/nixos-myflakes";
  };

  outputs = { self, nixpkgs, default, ... }: {
    nixosConfigurations.fabvarisco = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        default.nixosConfigurations.nixos.modules
        `./configuration.nix`
      ];
    };
  };
}
