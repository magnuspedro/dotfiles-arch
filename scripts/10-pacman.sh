#!/usr/bin/env bash
# Ajustes do pacman.conf: Color, ILoveCandy. Requer sudo.
set -euo pipefail
conf=/etc/pacman.conf

grep -q '^Color' "$conf" || sudo sed -i 's/^#Color/Color/' "$conf"
if ! grep -q '^ILoveCandy' "$conf"; then
  # ILoveCandy fica logo abaixo de Color (seção [options])
  sudo sed -i '/^Color/a ILoveCandy' "$conf"
fi
grep -nE '^(Color|ILoveCandy)' "$conf"
