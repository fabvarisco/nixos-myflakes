{
  description = "Exemplo de Flake para instalação via terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      # Um pacote simples que apenas expõe bash (exemplo)
      packages.x86_64-linux.my-package = pkgs.stdenv.mkDerivation {
        pname = "my-package";
        version = "1.0";

        # Apenas expondo bash como dependência para exemplificar
        buildInputs = [ pkgs.bash ];

        # Dummy buildPhase que não faz nada, só um exemplo simples
        buildPhase = "true";

        installPhase = ''
          mkdir -p $out/bin
          echo "Pacote simples instalado" > $out/bin/my-package-info
          chmod +x $out/bin/my-package-info
        '';
      };

      # Ambiente de desenvolvimento (devShell)
      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "my-shell";
        buildInputs = [
          pkgs.bash
          pkgs.git
          pkgs.vim
        ];

        shellHook = ''
          echo "Bem-vindo ao ambiente de desenvolvimento!"
        '';
      };

      # Definindo um pacote padrão para comandos que não especificam nome
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-package;
    };
}
