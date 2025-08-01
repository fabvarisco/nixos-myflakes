{
  description = "Minha configuracao de usuario universal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeManagerConfigurations."${builtins.getEnv "USER"}" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};

      modules = [
        # Coloque suas configuracoes de usuario universais aqui
        { home.stateVersion = "22.05"; }

        # Exemplo de como instalar alguns pacotes comuns
        { home.packages = with pkgs; [
            neovim
            zsh
            git
            htop
        ]; }

        # Exemplo de configuracao do Git
        { programs.git = {
            enable = true;
            userName = "${builtins.getEnv "USER"}";
            userEmail = "fabricio.varisco@outlook.com";
        }; }
      ];
    };
  };
}
