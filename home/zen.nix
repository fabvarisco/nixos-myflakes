{ config, pkgs, ... }:

{
  home.file.".config/zen".source = ../config/zen;
  home.file.".local/share/zen-startpage".source = ../config/zen/startpage;

  home.activation.zenBrowserSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ZEN_DIR="$HOME/.zen"
    ZEN_CONFIG="$HOME/.config/zen"

    if [ -d "$ZEN_DIR" ]; then
      for profile in "$ZEN_DIR"/*; do
        if [ -d "$profile" ] && [[ "$(basename "$profile")" != "Profile Groups" ]]; then
          mkdir -p "$profile/chrome"

          if [ -f "$ZEN_CONFIG/userChrome.css" ]; then
            rm -f "$profile/chrome/userChrome.css" 2>/dev/null
            cp "$ZEN_CONFIG/userChrome.css" "$profile/chrome/userChrome.css"
          fi

          if [ -f "$ZEN_CONFIG/user.js" ]; then
            rm -f "$profile/user.js" 2>/dev/null
            cp "$ZEN_CONFIG/user.js" "$profile/user.js"
          fi
        fi
      done
    fi
  '';
}
