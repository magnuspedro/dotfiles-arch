#!/usr/bin/env bash
# Bootstrap de um Arch novo. Idempotente: pode rodar mais de uma vez.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">> Atualizando sistema e instalando pacotes oficiais"
sudo pacman -Syu --needed --noconfirm
sudo pacman -S --needed --noconfirm - < "$DOTFILES/packages/pacman.txt"

if [[ -s "$DOTFILES/packages/aur.txt" ]]; then
  if ! command -v yay >/dev/null; then
    echo ">> Instalando yay"
    sudo pacman -S --needed --noconfirm base-devel git
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  fi
  echo ">> Instalando pacotes do AUR"
  yay -S --needed --noconfirm - < "$DOTFILES/packages/aur.txt"
fi

echo ">> Rodando scripts em scripts/"
for s in "$DOTFILES"/scripts/*.sh; do
  [[ -e "$s" ]] || continue
  echo "-- $(basename "$s")"
  bash "$s"
done
echo ">> Pronto."
