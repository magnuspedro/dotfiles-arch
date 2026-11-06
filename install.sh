#!/usr/bin/env bash
# Bootstrap interativo de um Arch novo. Idempotente.
#   ./install.sh          menu para escolher o que instalar
#   ./install.sh --all    instala tudo, sem perguntar
#   ./install.sh --list   só lista os módulos
# Sempre roda antes: scripts/00-base.sh e scripts/10-pacman.sh
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Módulos: "tipo|caminho|descrição"
#   pkgs = lista de pacotes pacman | aur = lista de pacotes AUR | script = scripts/NN-*.sh
modules=()
desc_of() { sed -n 's/^# DESC: *//p' "$1" | head -1; }

for f in "$DOTFILES"/packages/*.txt; do
  n="$(basename "$f" .txt)"
  case "$n" in
    aur|aur-*) modules+=("aur|$f|Pacotes do AUR (yay) — $(grep -vcE '^\s*(#|$)' "$f") itens") ;;
    *)   modules+=("pkgs|$f|Pacotes: $n — $(grep -vcE '^\s*(#|$)' "$f") itens") ;;
  esac
done
for f in "$DOTFILES"/scripts/*.sh; do
  case "$(basename "$f")" in 00-*|10-*) continue ;; esac
  modules+=("script|$f|$(desc_of "$f")")
done

list_modules() {
  local i=1 m
  for m in "${modules[@]}"; do
    IFS='|' read -r type path d <<<"$m"
    printf '  %2d) %-28s %s\n' "$i" "$(basename "$path")" "$d"
    ((i++))
  done
}

run_module() {
  local type path
  IFS='|' read -r type path _ <<<"$1"
  echo ">> $(basename "$path")"
  case "$type" in
    pkgs)   grep -vE '^\s*(#|$)' "$path" | sudo pacman -S --needed --noconfirm - ;;
    aur)    # yay não lê pacotes de stdin sem terminal: passa como argumentos
            mapfile -t aur_pkgs < <(grep -vE '^\s*(#|$)' "$path")
            yay -S --needed --noconfirm "${aur_pkgs[@]}" ;;
    script) bash "$path" ;;
  esac
}

selected=()
case "${1:-}" in
  --list) list_modules; exit 0 ;;
  --all)  selected=("${modules[@]}") ;;
  "")
    echo "Módulos disponíveis:"; list_modules
    read -rp "Números separados por espaço, 'a' para todos, Enter para nenhum: " answer
    if [[ "$answer" == a ]]; then
      selected=("${modules[@]}")
    else
      for i in $answer; do
        if [[ "$i" =~ ^[0-9]+$ ]] && (( i >= 1 && i <= ${#modules[@]} )); then
          selected+=("${modules[i-1]}")
        else
          echo "Ignorando entrada inválida: $i" >&2
        fi
      done
    fi ;;
  *) echo "Uso: $0 [--all|--list]" >&2; exit 1 ;;
esac

# Pré-requisitos (sempre)
bash "$DOTFILES/scripts/00-base.sh"
bash "$DOTFILES/scripts/10-pacman.sh"

# Pacotes antes de scripts (ex.: zsh precisa do pacote antes do chsh)
for m in "${selected[@]}"; do [[ "${m%%|*}" == pkgs ]] && run_module "$m"; done
for m in "${selected[@]}"; do [[ "${m%%|*}" == aur ]] && run_module "$m"; done
for m in "${selected[@]}"; do [[ "${m%%|*}" == script ]] && run_module "$m"; done
echo ">> Pronto."
