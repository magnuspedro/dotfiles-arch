#!/usr/bin/env bash
# DESC: tmux, alacritty, mise e fonte Hack Nerd + links das configs
# Requer sudo.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sudo pacman -S --needed --noconfirm tmux alacritty mise ttf-hack-nerd

link() { # link <origem no repo> <destino>
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d-%H%M%S)"
    echo "backup de $dst"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "$dst -> $src"
}

link "$DOTFILES/tmux/tmux.conf"   "$HOME/.tmux.conf"
link "$DOTFILES/alacritty"        "$HOME/.config/alacritty"
chmod +x "$DOTFILES/tmux/battery.sh"
