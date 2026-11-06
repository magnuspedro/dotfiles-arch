#!/usr/bin/env bash
# Instala zsh, linka o zshrc do repo e define zsh como shell padrão. Requer sudo.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sudo pacman -S --needed --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting

ln -sfn "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/zsh ]]; then
  sudo chsh -s /usr/bin/zsh "$USER"
fi
echo "Shell padrão: $(getent passwd "$USER" | cut -d: -f7) (vale no próximo login)"
