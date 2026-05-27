# dotfiles-desktop

CachyOS Hyprland rice: Hyprland + Quickshell + kitty + alacritty + GTK theming.
Only useful on a graphical workstation that runs (or will run) Hyprland.

For the portable dev environment (shell, tmux, neovim, sessionizer), see
[`dotfiles`](https://github.com/<your-username>/dotfiles) — install that
**first** on a fresh machine.

## Quick install

```bash
git clone https://github.com/<your-username>/dotfiles-desktop ~/dotfiles-desktop
cd ~/dotfiles-desktop
./install.sh
```

`install.sh` is idempotent — safe to re-run.

## Modules

| Module       | Target                  | Purpose                          |
|--------------|-------------------------|----------------------------------|
| `hypr`       | `~/.config/hypr/`       | Hyprland window manager config   |
| `quickshell` | `~/.config/quickshell/` | Bar, launcher, control center, wallpaper, notifications |
| `kitty`      | `~/.config/kitty/`      | Primary terminal                 |
| `alacritty`  | `~/.config/alacritty/`  | Secondary terminal               |
| `gtk`        | `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/` | GTK theming           |

## Per-machine customization

- **Monitor configuration** is hardcoded in `hypr/.config/hypr/hyprland.conf`
  for the author's setup (DP-1 @2560x1440, DP-2 @1920x1080 rotated). It's
  flagged with a banner — **delete or replace those `monitor =` lines on a
  new machine.** Run `hyprctl monitors` to discover the available outputs.

## Manual stow

```bash
cd ~/dotfiles-desktop
stow -t ~ hypr quickshell kitty alacritty gtk
```

`-D` to unstow, `-R` to re-stow.

## Bootstrap order on a fresh machine

1. **`dotfiles` first** — working shell + editor.
2. **This repo second** — install Hyprland stack, stow the rice, log out and
   pick the Hyprland session at login.
