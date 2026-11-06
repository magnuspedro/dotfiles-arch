#!/usr/bin/env bash
# DESC: Atalhos de Mac (Cmd+C/V/T...) com xremap, compilado do código-fonte com Rust pelo mise
# Requer sudo e o mise (scripts/30-mise.sh). Configuração em xremap/config.yml, baseada no Toshy.
# O xremap roda sem root, como o seu usuário (precisa do grupo input e de uma regra udev).
# Não há tecla de pânico: para desligar, feche o processo (pkill -x xremap) ou desabilite o autostart.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XREMAP_VERSION=0.15.17
XREMAP_BIN="$HOME/.cargo/bin/xremap"

command -v mise >/dev/null || { echo "Falta o mise (rode 30-mise.sh)" >&2; exit 1; }

# Rust e cargo vêm do mise (a versão está em mise/config.toml)
mise install rust

# Compila o xremap com o suporte ao KDE (regras por aplicativo), na versão fixada
if ! "$XREMAP_BIN" --version 2>/dev/null | grep -q "$XREMAP_VERSION"; then
  mise exec -- cargo install xremap --version "$XREMAP_VERSION" --locked --features kde
fi

# Permissões para rodar sem root: ler os teclados (grupo input) e criar o teclado virtual (uinput).
# Atenção: isso permite que o seu usuário leia as teclas digitadas (risco de keylogger).
sudo gpasswd -a "$USER" input
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess", MODE:="0660", OPTIONS+="static_node=uinput"' \
  | sudo tee /etc/udev/rules.d/99-input.rules >/dev/null
echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
sudo modprobe uinput
sudo udevadm control --reload-rules
sudo udevadm trigger

# Configuração e autostart (o autostart do KDE espera a sessão estar pronta, ao contrário de um serviço)
mkdir -p "$HOME/.config/xremap" "$HOME/.config/autostart"
ln -sfn "$DOTFILES/xremap/config.yml" "$HOME/.config/xremap/config.yml"
"$XREMAP_BIN" --validate-config "$HOME/.config/xremap/config.yml"
cat > "$HOME/.config/autostart/xremap.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=xremap (atalhos de Mac)
Exec=sh -c 'exec "$HOME/.cargo/bin/xremap" --watch=device,config "$HOME/.config/xremap/config.yml"'
X-KDE-autostart-after=panel
EOF

echo "xremap pronto. Ele inicia no próximo login (o grupo input só vale depois de um novo login)."
