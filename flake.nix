{
  description = "Default Nix flake config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-config.url = "github:fabvarisco/nixos-myflakes";
  };

  outputs = { self, nixpkgs, nixos-config, ... }: {
    nixosConfigurations.meu-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Importa a configuração base do flake
        nixos-config.nixosConfigurations.nixos.modules

        # Arquivos de configuracao
        ./configuration.nix
      ];
    };
  };
}
