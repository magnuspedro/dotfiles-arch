#!/usr/bin/env bash
# DESC: Visual tipo Mac: menu global no topo, dock embaixo, botões de janela à esquerda
# Recria os painéis do Plasma do zero (idempotente). Mantém os apps fixados no dock.
set -euo pipefail

TOP_HEIGHT=20
DOCK_HEIGHT=42
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Logo do Arch em amarelo Gruvbox (icons/arch-gruvbox.svg), copiado para o hicolor do usuário.
# Caminho absoluto: não depende do tema de ícones carregado.
ICON="$HOME/.local/share/icons/hicolor/scalable/apps/arch-gruvbox.svg"
mkdir -p "$(dirname "$ICON")"
cp "$DOTFILES/icons/arch-gruvbox.svg" "$ICON"
# Apps fixados no dock, na ordem
LAUNCHERS="applications:Alacritty.desktop,applications:firefox.desktop,applications:steam.desktop,applications:systemsettings.desktop"


# Botões de janela à esquerda, na ordem do Mac: fechar (X), minimizar (I), maximizar (A)
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft XIA
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true

# Overview (Mission Control): Ctrl+Cima, mantendo Meta+W (vale após novo login)
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key Overview $'Ctrl+Up\tMeta+W,Meta+W,Toggle Overview'

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
// 1) remove os painéis atuais
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

// 3) dock flutuante e centralizado embaixo
var dock = new Panel();
dock.location = 'bottom';
dock.height = $DOCK_HEIGHT;
dock.floating = true;
dock.lengthMode = 'fit';
dock.alignment = 'center';
dock.hiding = 'autohide';   // esconde sozinho; aparece ao encostar o mouse na borda
var t = dock.addWidget('org.kde.plasma.icontasks');
t.currentConfigGroup = ['General'];
t.writeConfig('launchers', '$LAUNCHERS');
t.reloadConfig();
" >/dev/null

echo "Painéis recriados: menu global no topo e dock embaixo."
