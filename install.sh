#!/usr/bin/env bash
# ~/dotfiles-desktop/install.sh — Hyprland rice bootstrap
#
# Idempotent: safe to re-run.
# Pairs with: ~/dotfiles/install.sh (the portable dev environment).
# Install dotfiles FIRST so you have a working shell + editor.

set -euo pipefail

# ── logging ──────────────────────────────────────────────────────────────
RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
step() { printf '\n%s▶ %s%s\n' "$BLUE" "$1" "$RESET"; }
ok()   { printf '%s✓ %s%s\n'   "$GREEN" "$1" "$RESET"; }
warn() { printf '%s! %s%s\n'   "$YELLOW" "$1" "$RESET"; }
die()  { printf '%s✗ %s%s\n'   "$RED" "$1" "$RESET" >&2; exit 1; }

# ── 1. preflight ─────────────────────────────────────────────────────────
step "preflight"
[[ $(id -u) -ne 0 ]] || die "run as your user, not root"
command -v pacman >/dev/null || die "requires an Arch-family distro (pacman not found)"
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[[ -d "$REPO_DIR/hypr" && -d "$REPO_DIR/quickshell" ]] || die "run this from inside the dotfiles-desktop repo (REPO_DIR=$REPO_DIR)"
cd "$REPO_DIR"
ok "running from $REPO_DIR"

# ── 2. back up pre-existing real files stow would refuse to overwrite ────
step "back up any conflicting real files"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date -u +%Y%m%dT%H%M%SZ)"
backed_up=0
backup_if_real() {
    local target=$1
    if [[ -e $target && ! -L $target ]]; then
        mkdir -p "$BACKUP_DIR/$(dirname "${target#$HOME/}")"
        mv "$target" "$BACKUP_DIR/${target#$HOME/}"
        backed_up=1
        warn "backed up $target → $BACKUP_DIR/${target#$HOME/}"
    fi
}
backup_if_real "$HOME/.config/hypr"
backup_if_real "$HOME/.config/quickshell"
backup_if_real "$HOME/.config/kitty"
backup_if_real "$HOME/.config/alacritty"
backup_if_real "$HOME/.config/gtk-3.0"
backup_if_real "$HOME/.config/gtk-4.0"
[[ $backed_up -eq 0 ]] && ok "nothing to back up"

# ── 3. AUR helper (bootstrap paru if neither paru nor yay is installed) ──
step "AUR helper"
if command -v paru >/dev/null; then
    AUR=paru
    ok "paru already installed"
elif command -v yay >/dev/null; then
    AUR=yay
    ok "yay already installed"
else
    warn "no AUR helper found — bootstrapping paru-bin"
    sudo pacman -S --needed --noconfirm base-devel git
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    AUR=paru
    ok "paru installed"
fi

# ── 4. packages (paru handles both pacman + AUR transparently) ───────────
step "installing Hyprland stack"
$AUR -S --needed --noconfirm \
    hyprland kitty alacritty dolphin \
    grim slurp wl-clipboard \
    pipewire wireplumber \
    hyprshot hyprlauncher quickshell \
    stow

# ── 5. stow rice modules ─────────────────────────────────────────────────
step "stow rice modules"
for m in hypr quickshell kitty alacritty gtk local; do
    stow -t "$HOME" -R "$m"
    ok "stowed $m"
done

# ── 5b. Vietnamese input (ibus-bamboo) Wayland fix ───────────────────────
# ibus-bamboo's bundled Wayland client crashes on Hyprland (its engine dies
# with "connection is closed" the moment it opens WAYLAND_DISPLAY). Force the
# engine through XWayland by stripping WAYLAND_DISPLAY from its exec line.
# This patches the package-installed component file (NOT stow-managed), so it
# must be re-applied whenever ibus-bamboo is reinstalled/updated.
BAMBOO_XML="$HOME/.local/share/ibus/component/bamboo.xml"
if [ -f "$BAMBOO_XML" ] && ! grep -q 'env -u WAYLAND_DISPLAY' "$BAMBOO_XML"; then
    step "patch ibus-bamboo component for Wayland (strip WAYLAND_DISPLAY)"
    sed -i 's#<exec>\(/[^<]*ibus-engine-bamboo --ibus\)</exec>#<exec>/usr/bin/env -u WAYLAND_DISPLAY \1</exec>#' "$BAMBOO_XML"
    ibus write-cache 2>/dev/null || true
    ok "patched $BAMBOO_XML"
fi

# ── done ────────────────────────────────────────────────────────────────
printf '\n%s━━━━ done ━━━━%s\n' "$GREEN" "$RESET"
cat <<'EOF'
Next steps:
  ⚠  Edit the monitor = lines in ~/.config/hypr/hyprland.conf for THIS machine.
     Run `hyprctl monitors` (after starting Hyprland once) to see your outputs.
     The committed config has the author's DP-1 + DP-2 setup with a clearly
     marked banner — delete or replace those lines.

  • Log out and pick "Hyprland" at the display manager, or start it manually
    with `Hyprland` from a TTY.
  • Inside Hyprland: SUPER+Q opens kitty, SUPER+R opens hyprlauncher,
    SUPER+D toggles the quickshell launcher.
EOF
[[ $backed_up -eq 1 ]] && printf '  • Pre-existing files backed up to: %s\n' "$BACKUP_DIR"
