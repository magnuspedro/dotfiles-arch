#!/usr/bin/env bash
# DESC: teclado US internacional (acentos) com Alt/Win trocados, como no Mac
# Requer sudo (só para o localectl, que vale também no login do SDDM).
set -euo pipefail

LAYOUT=us
VARIANT=intl
# altwin:swap_alt_win -> a tecla ao lado da barra de espaço vira Super (Cmd) e
# a seguinte vira Alt (Option), a mesma ordem física de um teclado Mac.
OPTIONS=altwin:swap_alt_win

# KDE Plasma (Wayland/X11)
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "$LAYOUT"
kwriteconfig6 --file kxkbrc --group Layout --key VariantList "$VARIANT"
kwriteconfig6 --file kxkbrc --group Layout --key Options "$OPTIONS"
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true
# Pede ao KWin para recarregar sem precisar relogar
dbus-send --session --type=signal /Layouts org.kde.keyboard.reloadConfig 2>/dev/null || true

# Sistema (tela de login)
sudo localectl set-x11-keymap "$LAYOUT" pc105 "$VARIANT" "$OPTIONS"

echo "Teclado: $LAYOUT ($VARIANT), opções: $OPTIONS"
