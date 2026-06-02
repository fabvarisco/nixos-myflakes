# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Management Commands

```bash
# Apply system changes (run as root or with sudo)
sudo nixos-rebuild switch --flake .#thinkpad-hypr
sudo nixos-rebuild switch --flake .#beelink-hypr
sudo nixos-rebuild switch --flake .#thinkpad-plasma
sudo nixos-rebuild switch --flake .#beelink-plasma

# Test a build without applying
sudo nixos-rebuild build --flake .#thinkpad-hypr

# Update flake inputs
nix flake update

# Update a single input
nix flake update hyprland

# Check flake validity
nix flake check
```

## Architecture Overview

This is a **NixOS flakes** dotfiles repository managing two hosts across two desktop environments.

### Entry Points

- `flake.nix` — defines all external inputs (nixpkgs, hyprland from git, home-manager, zen-browser, vicinae, etc.)
- `outputs.nix` — `mkHost` helper that assembles NixOS configurations; defines the four build targets: `thinkpad-hypr`, `beelink-hypr`, `thinkpad-plasma`, `beelink-plasma`

### Layer Structure

```
modules/          # Reusable system-level NixOS modules (imported by hosts)
  common.nix      # Bootloader, audio, bluetooth, SDDM, OneDrive — imported by all
  desktop/
    hyprland.nix  # Hyprland compositor + XDG portal
    plasma.nix    # KDE Plasma 6 + NetworkManager
  development.nix # Dev tools: git, vscode, claude-code, node, godot
  cpp.nix         # C/C++ toolchain (gcc, clang, cmake, gdb, SFML)
  gaming.nix      # Steam, GPU recorder, GameScope
  utils.nix       # CLI utilities
  fonts.nix       # JetBrains Mono Nerd Font

hosts/            # Per-machine hardware and system config
  thinkpad/       # TLP power management, fingerprint, AMD GPU, touchpad
  beelink/        # Gaming-focused, ROCm, Proton-GE, nix-ld

users/            # User-specific system configuration

home/             # Home-manager configurations (user environment)
  common.nix      # Shared: Zen browser, theming, dotfile symlinks, bash init
  hyprland.nix    # Hyprland-specific packages + wallpaper slideshow service
  plasma.nix      # Plasma-specific packages + KDE config symlinks
  zen.nix         # Zen browser profile setup
  vicinae.nix     # App launcher service
  nautilus.nix    # GNOME Files config
  cursor/miku.nix # Hatsune Miku cursor theme

config/           # The actual application config files (symlinked by home-manager)
  hyprland/       # Hyprland config + all scripts
  waybar/         # Waybar config + scripts
  swaync/         # Notification daemon config
  zen/            # Zen browser startpage + userChrome
  kitty/          # Terminal config
  starship/       # Shell prompt
  btop/           # System monitor
  claude/         # Claude Code agents and skills
```

### Theming System

The primary theming pipeline: **pywal** generates colors from the current wallpaper → colors are written to `~/.cache/wal/` → Hyprland, Waybar, and other apps source these colors. The `apply-pywal.sh` script drives this. Pywalfox bridges pywal colors into Zen Browser.

### Wallpaper System

Wallpapers live in `config/walls/`. The `wallpaper-slideshow` systemd user service (defined in `home/hyprland.nix`) runs `config/hyprland/wallpaper-slideshow.sh` every 12 hours.

### Hyprland Scripts

All scripts are in `config/hyprland/` and `config/hyprland/scripts/`. Monitor auto-configuration uses `hyprmon-auto.sh` and `hyprmon-watch.sh` to detect connected displays and apply profiles.

## Specialized Agents

For Hyprland configuration, scripting, or troubleshooting, use the `hyprland-specialist` agent. For NixOS module writing, flake configuration, or Nix expression debugging, use the `nix-nixos-specialist` agent. Both are available as Claude Code subagents in `config/claude/agents/`.

## Key Conventions

- All application configs live in `config/` and are symlinked into `~` by home-manager activation scripts in `home/*.nix`
- Hyprland is the **primary** DE; Plasma is secondary/fallback
- Timezone: `America/Sao_Paulo`; locale: `en_US.UTF-8` with `pt_BR` metadata
- ThinkPad battery thresholds are managed by TLP (75–80% charge limits)
- The Hyprland input from `flake.nix` tracks the git development version, not a stable release
