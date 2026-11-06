#!/usr/bin/env bash
# DESC: Botões de janela estilo macOS (fechar, minimizar, maximizar) nas cores do Gruvbox
# Gera o tema Aurorae "Gruvbox-Mac" a partir do WhiteSur-kde (GPL-3), recolorindo na instalação.
# Nada do WhiteSur é guardado neste repo; o tema final fica em ~/.local/share/aurorae.
set -euo pipefail

NAME=Gruvbox-Mac
REPO=https://github.com/vinceliuice/WhiteSur-kde.git
COMMIT=cf4df59ce91004f7ea39358b1b8ff917d5c329f7   # versão revisada (só copia arquivos)
DEST="$HOME/.local/share/aurorae/themes/$NAME"

# Paleta Gruvbox
RED='#fb4934'      # fechar
YELLOW='#fabd2f'   # minimizar
GREEN='#b8bb26'    # maximizar
BG1='#3c3836'      # barra de título
BG0='#282828'
BG0H='#1d2021'

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q src
git -C "$tmp/src" fetch -q --depth 1 "$REPO" "$COMMIT"
git -C "$tmp/src" checkout -q FETCH_HEAD
SRC="$tmp/src/aurorae"

rm -rf "$DEST"
mkdir -p "$DEST"
cp "$SRC/main/WhiteSur-dark/decoration.svg" "$DEST/"
cp "$SRC"/common/assets-dark/*.svg "$DEST/"
cp "$SRC/metadata.desktop" "$SRC/metadata.json" "$DEST/"
cp "$SRC/main/WhiteSur-darkrc" "$DEST/${NAME}rc"
sed -i "s/WhiteSur/$NAME/g" "$DEST/metadata.desktop" "$DEST/metadata.json"

# Botões: vermelho, amarelo e verde do macOS -> Gruvbox
sed -i -e "s/#e9524a/$RED/gI" -e "s/#f1ae1b/$YELLOW/gI" -e "s/#59c837/$GREEN/gI" "$DEST"/*.svg
# Barra de título e bordas: cinzas do WhiteSur -> fundos do Gruvbox
sed -i -e "s/#363636/$BG1/gI" -e "s/#2d2d2d/$BG0/gI" -e "s/#242424/$BG0/gI" -e "s/#1a1a1a/$BG0H/gI" "$DEST/decoration.svg"
# Texto do título: #ebdbb2 ativo, #928374 inativo
sed -i -e 's/^ActiveTextColor=.*/ActiveTextColor=235,219,178/' \
       -e 's/^InactiveTextColor=.*/InactiveTextColor=146,131,116/' \
       -e 's/^ActiveFocusedTabColor=.*/ActiveFocusedTabColor=60,56,54/' \
       -e 's/^LeftButtons=.*/LeftButtons=XIA/' "$DEST/${NAME}rc"
# Barra de título mais fina: o WhiteSur usa 8 + 16 + 8 = 32 px; aqui 3 + 10 + 3 = 16 px.
# Botões de 10 px, centralizados na barra (3 px de cada lado, sem margem extra).
sed -i -e 's/^TitleEdgeTop=.*/TitleEdgeTop=3/' \
       -e 's/^TitleEdgeBottom=.*/TitleEdgeBottom=3/' \
       -e 's/^TitleEdgeTopMaximized=.*/TitleEdgeTopMaximized=3/' \
       -e 's/^TitleEdgeBottomMaximized=.*/TitleEdgeBottomMaximized=3/' \
       -e 's/^TitleHeight=.*/TitleHeight=10/' \
       -e 's/^ButtonWidth=.*/ButtonWidth=10/' \
       -e 's/^ButtonHeight=.*/ButtonHeight=10/' \
       -e 's/^ButtonSpacing=.*/ButtonSpacing=7/' \
       -e 's/^ButtonMarginTop=.*/ButtonMarginTop=0/' "$DEST/${NAME}rc"

# Aplica: decoração Aurorae, botões à esquerda na ordem do Mac (X fechar, I minimizar, A maximizar)
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__$NAME"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft XIA
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true

echo "Decoração de janela: $NAME (aplicada; janelas abertas podem precisar ser reabertas)"
