#!/usr/bin/env bash
# DESC: Tema global "Gruvbox Dark" do KDE (cores, ícones, cursor, Kvantum, GTK, wallpaper, splash, lock screen)
# Instala o tema em ~/.local/share e o aplica. Depois dele aparece em
# Configurações do Sistema > Aparência > Tema Global.
# Os pacotes vêm de packages/theme.txt e packages/aur-theme.txt.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

COLORS=GruvboxDark
ICONS=Colloid-Gruvbox-Dark            # Colloid (estilo macOS) com pastas na paleta Gruvbox
COLLOID_REPO=https://github.com/vinceliuice/Colloid-icon-theme.git
COLLOID_COMMIT=ceac6608ecd0e40025cbc2ebbd32bf0e0f4ebc6a   # versão revisada do install.sh
CURSOR=Bibata-Modern-Classic-Gruvbox
KVANTUM=Gruvbox
GTK=gruvbox-dark-gtk
LAF=org.magnus.gruvbox
PLASMA_THEME=gruvbox

SHARE="$HOME/.local/share"
BASE_SCHEME=/usr/share/color-schemes/Gruvbox.colors      # do pacote kde-gruvbox-git
SCHEME_OUT="$SHARE/color-schemes/$COLORS.colors"
WALL_PKG="$SHARE/wallpapers/Gruvbox"
WALL="$WALL_PKG/contents/images/3840x2160.png"
LAF_DIR="$SHARE/plasma/look-and-feel/$LAF"

[[ -e "$BASE_SCHEME" ]] || { echo "Falta $BASE_SCHEME (instale os pacotes de tema primeiro)" >&2; exit 1; }
command -v rsvg-convert >/dev/null || { echo "Falta rsvg-convert (pacote librsvg)" >&2; exit 1; }

# 1) Esquema de cores completo.
#    O Gruvbox.colors do AUR não define [Colors:Complementary] (usado pela tela de bloqueio)
#    nem [Colors:Header]; sem elas o Plasma cai nas cores do Breeze. Copiamos a seção Window.
mkdir -p "$(dirname "$SCHEME_OUT")"
window="$(sed -n '/^\[Colors:Window\]/,/^$/p' "$BASE_SCHEME")"
{
  sed -e "s/^ColorScheme=Gruvbox$/ColorScheme=$COLORS/" -e 's/^Name=Gruvbox$/Name=Gruvbox Dark/' "$BASE_SCHEME"
  echo
  echo "${window/\[Colors:Window\]/[Colors:Complementary]}"
  echo "${window/\[Colors:Window\]/[Colors:Header]}"
  echo "${window/\[Colors:Window\]/[Colors:Header][Inactive]}"
} > "$SCHEME_OUT"

# 2) Wallpaper (pacote de wallpaper do KDE): fundo #282828 com o logo do Arch em amarelo
mkdir -p "$WALL_PKG/contents/images"
cat > "$WALL_PKG/metadata.json" <<'EOF'
{
    "KPackageStructure": "Wallpaper/Images",
    "KPlugin": {
        "Authors": [{ "Name": "Magnus" }],
        "Id": "Gruvbox",
        "License": "MIT",
        "Name": "Gruvbox"
    }
}
EOF
python3 -I - "$DOTFILES/icons/arch-gruvbox.svg" <<'PY' | rsvg-convert -o "$WALL" -
import re, sys
src = open(sys.argv[1]).read()
vw, vh = re.search(r'viewBox="0 0 (\d+) (\d+)"', src).groups()
path = re.search(r'<path[^>]*/>', src).group(0)
W, H, size = 3840, 2160, 520
x, y = (W - size) // 2, (H - size) // 2
print(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">'
      f'<rect width="{W}" height="{H}" fill="#282828"/>'
      f'<svg x="{x}" y="{y}" width="{size}" height="{size}" viewBox="0 0 {vw} {vh}">{path}</svg></svg>')
PY

# 2b) Ícones: Colloid com o esquema Gruvbox (instala em ~/.local/share/icons).
#     O instalador do projeto só copia arquivos; fixamos o commit que foi revisado.
if [[ ! -d "$SHARE/icons/$ICONS" ]]; then
  colloid_tmp="$(mktemp -d)"
  git -C "$colloid_tmp" init -q src
  git -C "$colloid_tmp/src" fetch -q --depth 1 "$COLLOID_REPO" "$COLLOID_COMMIT"
  git -C "$colloid_tmp/src" checkout -q FETCH_HEAD
  mkdir -p "$SHARE/icons"
  (cd "$colloid_tmp/src" && ./install.sh -s gruvbox -d "$SHARE/icons")
  rm -rf "$colloid_tmp"
fi
[[ -d "$SHARE/icons/$ICONS" ]] || { echo "Colloid não gerou $ICONS" >&2; exit 1; }
rm -rf "$SHARE/icons/Gruvbox-Plus-Blue"   # tema local antigo, não é mais usado

# 3) Tema global (Look-and-Feel): pacote do repo + esquema de cores, logo e previews
rm -rf "$LAF_DIR"
mkdir -p "$(dirname "$LAF_DIR")"
cp -r "$DOTFILES/plasma/look-and-feel/$LAF" "$LAF_DIR"
cp "$SCHEME_OUT" "$LAF_DIR/contents/colors"
mkdir -p "$LAF_DIR/contents/splash/images" "$LAF_DIR/contents/previews"
cp "$DOTFILES/icons/arch-gruvbox.svg" "$LAF_DIR/contents/splash/images/arch.svg"
python3 -I - "$WALL" "$LAF_DIR/contents/previews" "$WALL_PKG/contents/screenshot.png" <<'PY'
import sys
from PIL import Image
img = Image.open(sys.argv[1]).convert("RGB")
for name in ("preview.png", "splash.png", "lockscreen.png"):
    img.resize((1280, 720), Image.LANCZOS).save(f"{sys.argv[2]}/{name}")
img.resize((640, 360), Image.LANCZOS).save(sys.argv[3])
PY

# 4) Aplica o tema global (cores, ícones, cursor, estilo, splash, tema do Plasma)
lookandfeeltool -a "$LAF"
plasma-apply-colorscheme "$COLORS"
plasma-apply-desktoptheme "$PLASMA_THEME" || true
plasma-apply-cursortheme "$CURSOR"
/usr/lib/plasma-changeicons "$ICONS"   # grava e avisa o Plasma (aplica sem relogin)

# 5) Estilo dos widgets Qt: Kvantum com o tema Gruvbox
kvantummanager --set "$KVANTUM"
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum

# 6) GTK 3 e 4 (kde-gtk-config lê estes arquivos)
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

# 7) Wallpaper da área de trabalho e da tela de bloqueio
plasma-apply-wallpaperimage "$WALL"
kwriteconfig6 --file kscreenlockerrc --group Greeter --key WallpaperPlugin org.kde.image
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$WALL"
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "file://$WALL"

echo "Tema \"Gruvbox Dark\" instalado e aplicado."
