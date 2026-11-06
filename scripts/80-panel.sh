#!/usr/bin/env bash
# DESC: Barra de menu no topo (logo do Arch, menu global) e Overview; a dock é do Latte (85-latte.sh)
# Recria os painéis do Plasma do zero (idempotente). A dock embaixo fica por conta do Latte.
set -euo pipefail

TOP_HEIGHT=20
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Logo do Arch em amarelo Gruvbox (icons/arch-gruvbox.svg), copiado para o hicolor do usuário.
# Caminho absoluto: não depende do tema de ícones carregado.
ICON="$HOME/.local/share/icons/hicolor/scalable/apps/arch-gruvbox.svg"
mkdir -p "$(dirname "$ICON")"
cp "$DOTFILES/icons/arch-gruvbox.svg" "$ICON"

# Botões de janela à esquerda, na ordem do Mac: fechar (X), minimizar (I), maximizar (A)
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft XIA
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true

# Menu global para apps GTK: a sessão Wayland não lê o xinitrc.d do appmenu-gtk-module
mkdir -p "$HOME/.config/environment.d"
printf 'GTK_MODULES=appmenu-gtk-module\n' > "$HOME/.config/environment.d/90-appmenu.conf"

# Overview (Mission Control): Ctrl+Cima, mantendo Meta+W (vale após novo login)
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key Overview $'Ctrl+Up\tMeta+W,Meta+W,Toggle Overview'

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
// 1) remove os painéis atuais do Plasma (a dock do Latte é outro processo e não é afetada)
panels().slice().forEach(function (p) { p.remove(); });

// 2) barra de menu no topo: logo do Arch, menu global, espaço, bandeja, relógio
var top = new Panel();
top.location = 'top';
top.height = $TOP_HEIGHT;
top.floating = false;
top.lengthMode = 'fill';
top.hiding = 'none';
var k = top.addWidget('org.kde.plasma.kickoff');
k.currentConfigGroup = ['General'];
k.writeConfig('icon', '$ICON');
k.reloadConfig();
top.addWidget('org.kde.plasma.appmenu');
top.addWidget('org.kde.plasma.panelspacer');
top.addWidget('org.kde.plasma.systemtray');
top.addWidget('org.kde.plasma.digitalclock');
" >/dev/null

echo "Barra do topo recriada (a dock do Plasma foi removida; use 85-latte.sh)."
