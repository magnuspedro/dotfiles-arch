#!/usr/bin/env bash
# DESC: Bluetooth: habilita o serviço bluez (pacotes em packages/bluetooth.txt)
# Requer sudo. O adaptador é ligado sozinho (AutoEnable é true por padrão no bluez).
set -euo pipefail

sudo systemctl enable --now bluetooth.service
echo "Bluetooth ativo (pareie em Configurações do Sistema > Bluetooth ou com bluetoothctl)"
