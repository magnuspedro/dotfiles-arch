#!/usr/bin/env bash
# DESC: Dock estilo Mac com Latte (zoom parabólico, esconde sozinha) no lugar da dock do Plasma
# O pacote latte-dock-ng vem de packages/aur-dock.txt. O layout fica em latte/Gruvbox.layout.latte.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAYOUT=Gruvbox

command -v latte-dock-ng >/dev/null || { echo "Falta o latte-dock-ng (pacote do AUR)" >&2; exit 1; }

mkdir -p "$HOME/.config/latte"
cp "$DOTFILES/latte/$LAYOUT.layout.latte" "$HOME/.config/latte/$LAYOUT.layout.latte"

# Inicia a cada login e (re)inicia agora com o layout
latte-dock-ng --enable-autostart >/dev/null 2>&1 || true
nohup latte-dock-ng --replace --layout "$LAYOUT" >"$HOME/.config/latte/latte.log" 2>&1 &
disown
sleep 5
pgrep -x latte-dock-ng >/dev/null && echo "Latte rodando com o layout $LAYOUT" || { echo "Latte não iniciou; veja ~/.config/latte/latte.log" >&2; exit 1; }
