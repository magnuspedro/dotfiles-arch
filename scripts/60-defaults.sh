#!/usr/bin/env bash
# DESC: Alacritty como terminal padrão (KDE e xdg-terminal-exec)
set -euo pipefail

kwriteconfig6 --file kdeglobals --group General --key TerminalApplication alacritty
kwriteconfig6 --file kdeglobals --group General --key TerminalService Alacritty.desktop

# Spec xdg-terminal-exec (usada por vários apps e launchers)
mkdir -p ~/.config
echo "Alacritty.desktop" > ~/.config/xdg-terminals.list

echo "Terminal padrão: alacritty"
