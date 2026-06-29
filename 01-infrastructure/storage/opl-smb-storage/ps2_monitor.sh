# ==============================================================================
# Workload: ps2_monitor.sh
# Architecture Domain: Network Core
# Author: Kevin Oliveira
# ==============================================================================

#!/bin/bash

# --- CONFIGURAÇÕES ---
OPL_PS2_IP="x.x.x.x"  # Substitua pelo IP que deseja monitorar
TAG="Monitor-Shutdown"   # Tag para filtrar no journalctl

# --- EXECUÇÃO ---

# Realiza 10 tentativas de ping para evitar falso-positivo por oscilação de rede
if ping -c 10 "$OPL_PS2_IP" > /dev/null 2>&1; then
    # Se o IP responde, apenas registra no log
    logger -t "$TAG" "INFO: O PS2 está ligado. Nenhuma ação necessária."
else
    # Se o IP NÃO responde, registra o alerta e desliga o servidor
    logger -t "$TAG" "O PS2 está desligado ou inacessível. Iniciando desligamento do sistema..."
    
    # Comando para desligar (requer privilégios de root)
    /sbin/shutdown -h now
fi
