#!/usr/bin/env bash
# DESC: Atalhos de Mac (Cmd+C/V/T...) com keyd; o terminal usa Ctrl+Shift+C/V
# Requer sudo. O keyd fica habilitado para o PRÓXIMO login (não é iniciado agora),
# porque ele troca Cmd/Option no nível do teclado e a troca Alt/Win do XKB precisa já ter saído.
# Pânico: <backspace>+<escape>+<enter> desliga o keyd.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sudo pacman -S --needed --noconfirm keyd python-dbus

# O socket do keyd é do grupo "keyd": sem isso o mapeador por aplicativo não consegue
# conversar com o daemon e as regras do terminal nunca são aplicadas (vale após novo login).
sudo usermod -aG keyd "$USER"

sudo install -Dm644 "$DOTFILES/keyd/default.conf" /etc/keyd/default.conf
sudo keyd check /etc/keyd/default.conf
sudo systemctl enable keyd

# Mapeador por aplicativo (regras do terminal), iniciado a cada login do KDE
mkdir -p "$HOME/.config/keyd" "$HOME/.config/autostart"
ln -sfn "$DOTFILES/keyd/app.conf" "$HOME/.config/keyd/app.conf"
cat > "$HOME/.config/autostart/keyd-application-mapper.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=keyd application mapper
Exec=keyd-application-mapper -d
X-KDE-autostart-after=panel
EOF

echo "keyd habilitado. Reinicie o computador para ativar (ele inicia no boot, com o teclado já sem a troca do XKB)."
