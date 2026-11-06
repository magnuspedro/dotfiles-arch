#!/usr/bin/env bash
# DESC: Linguagens via mise (versões em mise/config.toml, ex.: Go)
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF="$HOME/.config/mise/config.toml"

command -v mise >/dev/null || { echo "mise não instalado (rode 25-terminal.sh)" >&2; exit 1; }

mkdir -p "$(dirname "$CONF")"
if [[ -e "$CONF" && ! -L "$CONF" ]]; then
  mv "$CONF" "$CONF.bak.$(date +%Y%m%d-%H%M%S)"
fi
ln -sfn "$DOTFILES/mise/config.toml" "$CONF"

# Instala o que estiver declarado no config
mise install
mise ls
