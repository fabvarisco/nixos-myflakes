{ ... }:

let
  d = "/home/fabvarisco/my-dotfiles";
  h = "/home/fabvarisco";
in {
  system.activationScripts.userDotfiles = {
    text = ''
      mkdir -p ${h}/.config ${h}/.claude

      ln -sfn ${d}/config/shared/kitty           ${h}/.config/kitty
      ln -sfn ${d}/config/shared/btop            ${h}/.config/btop
      ln -sfn ${d}/config/shared/starship.toml   ${h}/.config/starship.toml
      ln -sfn ${d}/config/shared/fastfetch       ${h}/.config/fastfetch
      ln -sfn ${d}/config/walls                  ${h}/.config/walls
      ln -sfn ${d}/config/profile-pics           ${h}/.config/profile-pics
      ln -sfn ${d}/config/niri                   ${h}/.config/niri
      ln -sfn ${d}/config/noctalia               ${h}/.config/noctalia
      ln -sfn ${d}/config/claude/agents          ${h}/.claude/agents
      ln -sfn ${d}/config/claude/skills          ${h}/.claude/skills
    '';
  };

  system.activationScripts.zenBrowserSetup = {
    text = ''
      if [ -d "${h}/.zen" ]; then
        for profile in ${h}/.zen/*/; do
          [ -d "$profile" ] || continue
          name="$(basename "$profile")"
          [ "$name" = "Profile Groups" ] && continue
          mkdir -p "$profile/chrome"
          cp ${d}/config/zen/userChrome.css "$profile/chrome/"
          cp ${d}/config/zen/user.js        "$profile/"
        done
      fi
    '';
  };
}
