#!/usr/bin/env bash
# DESC: Neovim + sua config (github.com/magnuspedro/nvim)
# Instala o neovim e clona a config (github.com/magnuspedro/nvim). Requer sudo.
set -euo pipefail
REPO=https://github.com/magnuspedro/nvim.git
DEST="$HOME/.config/nvim"

sudo pacman -S --needed --noconfirm neovim ripgrep fd tree-sitter-cli xclip wl-clipboard

if [[ -d "$DEST/.git" ]]; then
  echo ">> Config já existe, atualizando"
  git -C "$DEST" pull --ff-only
elif [[ -e "$DEST" ]]; then
  echo "$DEST existe e não é um repo git; não vou sobrescrever." >&2
  exit 1
else
  mkdir -p "$(dirname "$DEST")"
  git clone "$REPO" "$DEST"
fi
