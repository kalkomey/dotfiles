# Phase 2 — Linux desktop (Hyprland)

**Status: deferred. Not implemented.** This document captures the plan so it isn't lost;
no desktop config ships in the repo yet.

## Why it's separate

The current dotfiles bring a **developer environment** to parity across macOS and Ubuntu.
A desktop layer is different in kind: it's **Linux-only** (macOS supplies its own window
manager — Aqua), so it has no macOS counterpart and doesn't fit the two-column package
matrix. It's a net-new topic area, sequenced after the dev-environment work is verified.

Tommy is standing up an **Ubuntu 24.04 LTS + Hyprland** machine; this is the target.

## Target stack (grounded, ~2026)

Hyprland is deliberately *not a desktop environment* — you assemble the pieces. Config
lives under `~/.config/<tool>/`.

| Component | Choice | Notes |
|---|---|---|
| Compositor | **Hyprland** | Not in 24.04 apt; install via the **cpiber PPA** (`ppa:cppiber/hyprland`, ships 0.54.x for noble), or the JaKooLit `Ubuntu-Hyprland` installer (24.04 branch). |
| Status bar | **Waybar** | `~/.config/waybar/{config,style.css}` |
| App launcher | **fuzzel** (or wofi) | Wayland-native |
| Terminal | **kitty** (ghostty rising; foot for minimal) | `~/.config/kitty/kitty.conf` |
| Notifications | **mako** | `~/.config/mako/config` |
| Clipboard | **wl-clipboard** + **cliphist** | already used by `system/clipboard.zsh` |
| Screenshots | **hyprshot** (wraps grim+slurp) | bound in `hyprland.conf` |
| Idle / lock | **hypridle** + **hyprlock** | |
| Wallpaper | **hyprpaper** (static) or **swww** (animated) | |
| Output/display | `monitor=` lines; **nwg-displays** for a GUI | |

## Gotchas

- 24.04 ships GNOME/Wayland; Hyprland coexists as a separate session.
- The base repo's `wayland-protocols`/deps are too old to build Hyprland from source — the
  PPA carries the newer deps. Building from source is discouraged for general use.
- NVIDIA needs extra Wayland env vars.

## When this gets built

It becomes a new topic area (e.g. `hypr/` with `hyprland.conf.symlink`, plus `waybar/`,
`kitty/`, etc.), Linux-guarded so it no-ops on macOS, with its own `install.sh` using the
cpiber PPA. Add the desktop tools to `docs/package-matrix.md` as Linux-only rows (macOS =
n/a) when that happens.
