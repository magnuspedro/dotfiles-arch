#!/usr/bin/env bash
# Ferramentas base. Requer sudo (não rode como root).
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Não rode como root; o script usa sudo quando precisa." >&2
  exit 1
fi
echo ">> Verificando sudo"
sudo -v || { echo "sudo indisponível" >&2; exit 1; }

BASE_PKGS=(git base-devel curl wget openssh unzip rsync man-db man-pages pacman-contrib)

echo ">> Atualizando sistema e instalando pacotes base"
sudo pacman -Syu --needed --noconfirm "${BASE_PKGS[@]}"

echo ">> Habilitando limpeza semanal do cache do pacman"
sudo systemctl enable --now paccache.timer

if ! command -v yay >/dev/null; then
  echo ">> Instalando yay (AUR helper)"
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi
echo ">> Base pronta."
