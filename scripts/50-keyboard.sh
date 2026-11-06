#!/usr/bin/env bash
# DESC: teclado US internacional (acentos); a troca Cmd/Option fica a cargo do xremap (52-xremap.sh)
# Requer sudo (só para o localectl, que vale também no login do SDDM).
set -euo pipefail

LAYOUT=us
VARIANT=intl
# Sem opções de troca Alt/Win: quem faz Cmd/Option é o xremap.
# Se as duas trocas estivessem ativas, uma anularia a outra.
OPTIONS=""

# KDE Plasma (Wayland/X11); o KWin só relê o layout no próximo login
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "$LAYOUT"
kwriteconfig6 --file kxkbrc --group Layout --key VariantList "$VARIANT"
kwriteconfig6 --file kxkbrc --group Layout --key Options "$OPTIONS"
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true

# Sistema (tela de login)
sudo localectl set-x11-keymap "$LAYOUT" pc105 "$VARIANT" "$OPTIONS"

echo "Teclado: $LAYOUT ($VARIANT), sem troca Alt/Win (o xremap cuida do Cmd/Option)"
