## CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal NixOS flake managing two machines (`thinkpad`, `beelink`) running Hyprland. NixOS system config and home-manager are composed in a single flake; there is no separate home-manager entry point.

## Apply / rebuild

```bash
sudo nixos-rebuild switch --flake .#thinkpad-hypr   # ThinkPad
sudo nixos-rebuild switch --flake .#beelink-hypr    # Beelink
```

Useful checks before rebuilding:

```bash
nix flake check
nix build .#nixosConfigurations.thinkpad-hypr.config.system.build.toplevel --no-link
nix flake update           # bump all inputs
nix flake lock --update-input vicinae   # bump one input
```

There is no test suite, no linter config, and no Makefile/justfile. Validation = the flake builds and the resulting system boots/works.

## Composition (read `outputs.nix` first)

`outputs.nix` defines `mkHost { hostname, desktop, user ? defaultUser }` which produces a `nixosSystem` with:

- System side: `hosts/${hostname}/configuration.nix` + `modules/desktop/${desktop}.nix`. Hosts always `imports = [ ../../modules/common.nix ]`, which pulls in `modules/{development,cpp,gaming,calendar,utils,fonts}.nix` and `users/default.nix`.
- Home-manager (as a NixOS module, `useGlobalPkgs = true`): for `user.username`, imports `home/common.nix` + `home/${desktop}.nix` + `home/cursor/miku.nix`. Both `specialArgs` (NixOS) and `extraSpecialArgs` (home-manager) thread `{ inputs, user }`.

The `user` attrset (`{ username, fullName, homeDirectory }`) is the single source of truth for identity — consumed by `users/default.nix` (account), `modules/common.nix` (SDDM `profileIcons`), and `home/hyprland.nix` (templates `@USERNAME@` in `hyprland.conf` via `substituteInPlace`). Override per host by passing `user = { ... }` to `mkHost`.

To add a new host: drop `hosts/<name>/{configuration,hardware-configuration}.nix`, register it in `outputs.nix` via `mkHost`. To add a new desktop: add `modules/desktop/<name>.nix` (system) **and** `home/<name>.nix` (home) — both file names must match the `desktop` argument.

## Config files (the `config/` tree)

Most user-facing app configs (`hyprland`, `kitty`, `btop`, `starship`, `fastfetch`, `wlogout`, `walls`, `profile-pics`, plus `claude/agents` and `claude/skills`) live as plain files under `config/` and are linked into `~/.config` (or `~/.claude`) via `home.file."...".source = ../config/...` in `home/common.nix` and `home/hyprland.nix`. Edit those files directly — no Nix rebuild needed for most changes; reload the relevant app (e.g. `hyprctl reload`). A NixOS rebuild is only needed when the symlink target itself changes (new file added, source path changed).

Exception: scripts under `config/hyprland/` and `config/hyprland/scripts/` are invoked by their installed path (`~/.config/hypr/...`); the symlink makes them executable in place.

## Notable wiring

- **Vicinae launcher**: `home/vicinae.nix` uses `inputs.vicinae.packages.<system>.mkVicinaeExtension` with sources from the `vicinae-extensions` flake input (`flake = false`). Add extensions to the `services.vicinae.extensions` list using the `ext "<name>"` helper, where `<name>` is the directory under `vicinae-extensions/extensions/`.
- **Hyprland package**: pinned to `inputs.hyprland.packages.<system>.hyprland` in `modules/desktop/hyprland.nix` (the flake input uses `?submodules=1`, so this differs from nixpkgs' hyprland).
- **SDDM**: `silentSDDM` NixOS module enabled in `modules/common.nix` with theme `rei`.
- **Custom Claude agents**: `config/claude/agents/*.md` are symlinked to `~/.claude/agents/` by `home/common.nix:24-25`. The `hyprland-specialist` and `nix-nixos-specialist` agent types in this environment come from these files — edits there change agent behavior after the next `nixos-rebuild switch` (or by re-linking).
- **Branch**: current work happens on `nixos/hyprland-astal`. `main` is the PR base.

## Conventions

- Flake inputs are threaded through `specialArgs.inputs` and `extraSpecialArgs.inputs`. Reference them as `inputs.<name>` in any module.
- `nixpkgs.config.allowUnfree = true` is set in `modules/common.nix` — no need to repeat.
- `system.stateVersion = "25.05"` per host; do not change without intent.
- Locale: English UI, pt_BR formatting (`modules/common.nix`); timezone `America/Sao_Paulo`.
- Substituters/keys for `hyprland.cachix.org` and `nix-community.cachix.org` are declared in both `flake.nix` (`nixConfig`) and `modules/common.nix` (`nix.settings`) — keep both in sync when adding caches.
