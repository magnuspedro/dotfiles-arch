#!/usr/bin/env bash
# DESC: Cedilha no teclado US internacional (' + c = ç) via ~/.XCompose
# Com o locale en_US, ' + c produz "ć". O arquivo mantém a tabela do locale e só
# corrige o cedilha. Vale para apps abertos depois (Qt, GTK, Alacritty).
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -e "$HOME/.XCompose" && ! -L "$HOME/.XCompose" ]]; then
  mv "$HOME/.XCompose" "$HOME/.XCompose.bak.$(date +%Y%m%d-%H%M%S)"
fi
ln -sfn "$DOTFILES/xcompose/XCompose" "$HOME/.XCompose"
echo "~/.XCompose -> $DOTFILES/xcompose/XCompose"
