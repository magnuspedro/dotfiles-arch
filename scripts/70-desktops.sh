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

# Atalhos (estilo Mac): Ctrl+←/→ troca de área, Ctrl+F1..F5 vai direto para a área N.
# Os atalhos padrão do KDE com Meta continuam como segunda opção.
sc() { kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "$1" "$2"; }
sc "Switch One Desktop to the Left"  $'Ctrl+Left,Meta+Ctrl+Left,Switch One Desktop to the Left'
sc "Switch One Desktop to the Right" $'Ctrl+Right,Meta+Ctrl+Right,Switch One Desktop to the Right'
for ((i = 1; i <= N; i++)); do
  sc "Switch to Desktop $i" "Ctrl+F$i,Ctrl+F$i,Switch to Desktop $i"
done

# Aplica ao vivo no kglobalaccel (flags 6 = SetPresent|NoAutoloading); sem isso só vale no próximo login
setkey() { # ação, código Qt da tecla
  busctl --user call org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel setShortcut asaiu \
    4 kwin "$1" KWin "$1" 1 "$2" 6 >/dev/null 2>&1 || true
}
setkey "Switch One Desktop to the Left" 83886098   # Ctrl+Left
setkey "Switch One Desktop to the Right" 83886100  # Ctrl+Right
for ((i = 1; i <= N; i++)); do
  setkey "Switch to Desktop $i" $((0x05000030 + i - 1))   # Ctrl+F1..F5 (F1 = 0x01000030)
done
echo "Atalhos: Ctrl+←/→ troca de área, Ctrl+F1..F$N vai para a área"
