{ inputs, config, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell.enable = true;

  # settings.json gerenciado fora do store (gravável) -> versionado no repo.
  # Edita pela UI do noctalia; muda o arquivo no repo; commit + pull sincroniza.
  home.file.".config/noctalia/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/my-dotfiles/config/shared/noctalia/settings.json";
}
