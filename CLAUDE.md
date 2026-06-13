# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Applying Configuration

```bash
# Build and switch (on the target machine)
sudo nixos-rebuild switch --flake .#thinkpad-hypr
sudo nixos-rebuild switch --flake .#beelink-hypr

# Test without switching (builds only)
nix build .#nixosConfigurations.thinkpad-hypr.config.system.build.toplevel

# Check flake inputs and update
nix flake show
nix flake update          # update all inputs
nix flake update hyprland # update a single input
```

Binary caches are configured in `flake.nix` (`nixConfig`): `hyprland.cachix.org` and `nix-community.cachix.org` supplement the default cache. Run `cachix use hyprland` if cache misses occur on a new machine.

## Architecture

This is a **NixOS flake** managing two machines (`thinkpad`, `beelink`) with Hyprland as the desktop environment.

### Configuration flow

```
flake.nix → outputs.nix → mkHost { hostname, desktop }
                            ├── hosts/<hostname>/configuration.nix   (machine-specific: hardware, CPU/GPU)
                            ├── modules/desktop/hyprland.nix         (desktop environment)
                            ├── silentSDDM.nixosModules.default       (login manager)
                            └── home-manager → users/fabvarisco/home.nix + system.nix

modules/desktop/hyprland.nix
  └── imports modules/vicinae.nix
modules/desktop/hyprland.nix imports modules/common.nix implicitly via hosts

modules/common.nix
  └── imports development.nix, cpp.nix, gaming.nix, calendar.nix, utils.nix, fonts.nix, users/default.nix
```

### Config file deployment

Dotfiles under `config/` are deployed as `xdg.configFile` symlinks via **home-manager** (not systemd.tmpfiles). Two files manage these symlinks:

**`users/fabvarisco/home.nix`** (user-level, shared across desktops):
- `config/hyprland/` → `~/.config/hypr/`
- `config/shared/kitty/` → `~/.config/kitty/`
- `config/shared/btop/` → `~/.config/btop/`
- `config/shared/starship.toml` → `~/.config/starship.toml`
- `config/shared/fastfetch/` → `~/.config/fastfetch/`
- `config/walls/` → `~/.config/walls/`
- `config/zen/userChrome.css`, `user.js` → `~/.config/zen/`
- `config/claude/agents/`, `skills/` → `~/.claude/agents/`, `~/.claude/skills/`

**`modules/desktop/hyprland.nix`** (desktop-specific):
- `config/hyprland/eww/` → `~/.config/eww/`
- `config/hyprland/swaync/` → `~/.config/swaync/`
- `config/hyprland/wlogout/` → `~/.config/wlogout/`
- `config/shared/wal/templates/` → `~/.config/wal/templates/`
- `config/shared/wal/colors-eww-default.scss` + `colors-swaync-default.css` → `~/.config/wal/`

Note that `~/.config/eww/` is a subdirectory of `~/.config/hypr/` (since the whole `config/hyprland/` tree is linked to `hypr`), so eww and hyprland.nix both manage overlapping paths — the explicit `eww` entry in hyprland.nix takes precedence for that subtree.

`config/wiremix/` and `config/yazi/` are **not** currently symlinked.

The symlinks point to Nix store paths (built from `config/` at build time), so **all changes** require `nixos-rebuild switch` to take effect. During development, you can temporarily redirect a symlink directly to the working directory (e.g. `ln -sfn ~/Developer/my-dotfiles/config/hyprland/eww ~/.config/eww`) and reload EWW with `eww reload`, but the next rebuild will reset it to the Nix store path. For Hyprland config changes, `hyprctl reload` applies `hyprland.conf` without a rebuild.

### Key external inputs

- **hyprland**: tracks upstream git (not nixpkgs version)
- **vicinae**: application launcher with nix + bluetooth extensions built in `modules/desktop/hyprland.nix`
- **zen-browser**: Firefox fork via `youwen5/zen-browser-flake`
- **silentSDDM**: custom SDDM theme (theme set to `rei` in `modules/common.nix`)

### Theming pipeline

Pywal generates color schemes from wallpapers → templates in `config/shared/wal/templates/` produce EWW SCSS and Swaync CSS overrides. `config/hyprland/apply-pywal.sh` orchestrates this. Default fallback colors live in `config/shared/wal/colors-eww-default.scss` and `colors-swaync-default.css`.

### EWW widgets

`config/hyprland/eww/eww.yuck` defines the widget markup; `eww.scss` handles styling. Scripts in `config/hyprland/eww/scripts/` (and `config/hyprland/cal-data.sh`, `toggle-calendar.sh`) power dynamic data. EWW is symlinked to `~/.config/eww/`, so widget changes are live — reload with `eww reload`.

### Wallpaper management

`config/walls/` contains wallpapers. `wallpaper-slideshow.sh` runs as a systemd user service (defined in `modules/desktop/hyprland.nix`), cycling wallpapers every 12 hours via `hyprpaper`. `wallpaper-vicinae.sh` integrates with the Vicinae launcher.

### Hosts

| Host | Key specifics |
|------|--------------|
| `thinkpad` | AMD CPU, ROCm graphics, ThinkPad power tuning |
| `beelink` | Minimal config, same modules |

Both share `modules/common.nix` which sets timezone (`America/Sao_Paulo`), iwd networking, PipeWire audio, Gnome Keyring, Bluetooth, and OneDrive.

## Custom Claude Agents

`config/claude/agents/` contains specialized agent definitions:
- `nix-nixos-specialist.md` — deep NixOS/flakes expertise
- `hyprland-specialist.md` — Hyprland config and ecosystem
- `shift-rpg-expert.md` — SHIFT tabletop RPG rules

These are synced to `~/.claude/agents/` as part of system configuration.
