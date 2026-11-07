#!/usr/bin/env bash
# DESC: teclado US internacional (acentos), com as teclas no padrão do Linux
# Requer sudo (só para o localectl, que vale também no login do SDDM).
set -euo pipefail

LAYOUT=us
VARIANT=intl
# Sem opções de troca de teclas: padrão do Linux.
OPTIONS=""

# KDE Plasma (Wayland/X11); o KWin só relê o layout no próximo login
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "$LAYOUT"
kwriteconfig6 --file kxkbrc --group Layout --key VariantList "$VARIANT"
kwriteconfig6 --file kxkbrc --group Layout --key Options "$OPTIONS"
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true

# Sistema (tela de login)
sudo localectl set-x11-keymap "$LAYOUT" pc105 "$VARIANT" "$OPTIONS"

echo "Teclado: $LAYOUT ($VARIANT), teclas no padrão do Linux"
