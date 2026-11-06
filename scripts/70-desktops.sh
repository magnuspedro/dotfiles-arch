#!/usr/bin/env bash
# DESC: 5 áreas de trabalho virtuais no KDE, em uma linha
set -euo pipefail
N=5

kwriteconfig6 --file kwinrc --group Desktops --key Number "$N"
kwriteconfig6 --file kwinrc --group Desktops --key Rows 1

# Aplica na sessão atual (criando os que faltam)
current=$(qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.count 2>/dev/null || echo 0)
for ((i = current; i < N; i++)); do
  qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.createDesktop "$i" "Desktop $((i + 1))" >/dev/null
done
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true
echo "Áreas de trabalho: $(qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.count)"
