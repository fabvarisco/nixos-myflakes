{
  description = "Exemplo de Flake para instalação via terminal";

  # Definindo os inputs (nixpkgs e outros flakes, se necessários)
  inputs = {
    # Referência ao repositório nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    # Outros inputs (se necessário)
    # exemplo: flakes para ferramentas ou pacotes específicos
    # devshell.url = "github:some/flake";
  };

  # Definindo os outputs, incluindo pacotes, apps, e configurações
  outputs = { self, nixpkgs, ... }: {
    # Expondo pacotes para x86_64-linux, você pode adicionar mais se necessário
    packages.x86_64-linux.my-package = with nixpkgs.legacyPackages.x86_64-linux; buildInputs.mkShell {
      name = "my-package";  # Nome do pacote
      buildInputs = [ bash ];  # Dependências do pacote, ex: bash, vim, etc.
    };

    # Se quiser criar um ambiente de shell interativo para desenvolvimento
    # Usando mkShell para ambientes personalizados
    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      name = "my-shell";
      buildInputs = [
        bash
        git
        vim
      ];

      shellHook = ''
        echo "Bem-vindo ao ambiente de desenvolvimento!"
      '';
    };

    # Também podemos adicionar uma configuração default, o que facilita
    # quando o usuário apenas quiser rodar o flake sem precisar especificar o nome
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-package;
  };
}
