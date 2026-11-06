#!/usr/bin/env bash
# Ajustes do pacman.conf: Color, ILoveCandy. Requer sudo.
set -euo pipefail
conf=/etc/pacman.conf

grep -q '^Color' "$conf" || sudo sed -i 's/^#Color/Color/' "$conf"
if ! grep -q '^ILoveCandy' "$conf"; then
  # ILoveCandy fica logo abaixo de Color (seção [options])
  sudo sed -i '/^Color/a ILoveCandy' "$conf"
fi

# Habilita [multilib] (necessário para Steam e libs lib32)
if ! grep -q '^\[multilib\]' "$conf"; then
  sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' "$conf"
fi
sudo pacman -Sy

grep -nE '^(Color|ILoveCandy)' "$conf"
grep -A1 '^\[multilib\]' "$conf"
