#!/usr/bin/env bash
# DESC: Zsh + oh-my-zsh, tema spaceship, plugins, ~/.zshrc do repo e shell padrão
# Requer sudo (só para o pacman e o chsh).
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM="$ZSH_DIR/custom"

sudo pacman -S --needed --noconfirm zsh zsh-completions git

# clone <url> <destino>: clona se não existir, senão atualiza
clone() {
  if [[ -d "$2/.git" ]]; then
    git -C "$2" pull --ff-only --quiet
  else
    git clone --depth 1 --quiet "$1" "$2"
  fi
}

# oh-my-zsh (clonado direto: o instalador oficial sobrescreveria o ~/.zshrc)
clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"

# Tema spaceship
clone https://github.com/spaceship-prompt/spaceship-prompt.git "$CUSTOM/themes/spaceship-prompt"
ln -sfn "$CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$CUSTOM/themes/spaceship.zsh-theme"

# Plugins (além do git, que já vem com o oh-my-zsh)
clone https://github.com/zsh-users/zsh-autosuggestions.git      "$CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting.git  "$CUSTOM/plugins/zsh-syntax-highlighting"

ln -sfn "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/zsh ]]; then
  sudo chsh -s /usr/bin/zsh "$USER"
fi
echo "Shell padrão: $(getent passwd "$USER" | cut -d: -f7) (vale no próximo login)"
