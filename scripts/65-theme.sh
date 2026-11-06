#!/usr/bin/env bash
# DESC: Tema Gruvbox Dark no KDE: cores, ícones, cursor, Kvantum, GTK, wallpaper e lock screen
# Os pacotes vêm de packages/theme.txt e packages/aur-theme.txt.
set -euo pipefail

COLORS=Gruvbox
PLASMA_THEME=gruvbox
ICONS=Gruvbox-Plus-Dark
CURSOR=Bibata-Modern-Classic-Gruvbox
KVANTUM=Gruvbox
GTK=gruvbox-dark-gtk
WALL=/usr/share/backgrounds/gruvbox/gruvbox-dark-archlinux-scalable.svg

for f in "/usr/share/color-schemes/$COLORS.colors" "$WALL"; do
  [[ -e "$f" ]] || { echo "Falta $f (instale os pacotes de tema primeiro)" >&2; exit 1; }
done

# Cores, tema do Plasma, cursor
plasma-apply-colorscheme "$COLORS"
plasma-apply-desktoptheme "$PLASMA_THEME" || true
plasma-apply-cursortheme "$CURSOR"

# Ícones
/usr/lib/plasma-changeicons "$ICONS"   # grava e avisa o Plasma (aplica sem relogin)

# Estilo dos widgets Qt: Kvantum com o tema Gruvbox
kvantummanager --set "$KVANTUM"
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum

# GTK 3 e 4 (kde-gtk-config lê estes arquivos)
for v in 3.0 4.0; do
  mkdir -p "$HOME/.config/gtk-$v"
  cat > "$HOME/.config/gtk-$v/settings.ini" <<EOF
[Settings]
gtk-theme-name=$GTK
gtk-icon-theme-name=$ICONS
gtk-cursor-theme-name=$CURSOR
gtk-application-prefer-dark-theme=1
EOF
done

# Wallpaper da área de trabalho e da tela de bloqueio
plasma-apply-wallpaperimage "$WALL"
kwriteconfig6 --file kscreenlockerrc --group Greeter --key WallpaperPlugin org.kde.image
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$WALL"
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "file://$WALL"

echo "Tema Gruvbox aplicado. Alguns apps só pegam o tema ao serem reabertos (ou após novo login)."
