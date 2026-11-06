#!/bin/sh
# Bateria pra status bar do tmux (macOS e Linux). Sem bateria (desktop) não mostra nada.
# Ícone muda com o nível; verde na tomada, amarelo <= 40%, vermelho <= 20%.
ICONS="󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹"

render() { # $1 = porcentagem, $2 = 1 se descarregando
  awk -v p="$1" -v d="$2" -v icons="$ICONS" 'BEGIN {
    split(icons, ic, " ")
    i = int((p + 5) / 10); if (i < 1) i = 1; if (i > 10) i = 10
    icon = ic[i]; color = "#ebdbb2"
    if (!d) { icon = "󰂄"; color = "#b8bb26" }
    else if (p <= 20) color = "#fb4934"
    else if (p <= 40) color = "#fabd2f"
    printf "#[fg=%s]%s %d%%", color, icon, p
  }'
}

if command -v pmset >/dev/null; then
  # macOS
  pmset -g batt | awk -F'[;\t]' '/InternalBattery/ { gsub(/ /,"",$2); gsub(/ /,"",$3); print $2+0, ($3 ~ /^discharging/) ? 1 : 0 }' |
    while read -r p d; do render "$p" "$d"; done
else
  # Linux
  for b in /sys/class/power_supply/BAT*; do
    [ -r "$b/capacity" ] || continue
    p=$(cat "$b/capacity")
    [ "$(cat "$b/status")" = Discharging ] && d=1 || d=0
    render "$p" "$d"
    break
  done
fi
