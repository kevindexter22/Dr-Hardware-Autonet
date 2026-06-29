# ==============================================================================
# Workload: hdd_mount_script
# Architecture Domain: Network Core
# Author: Kevin Oliveira
# ==============================================================================

#!/bin/bash

# UUID configurado no /etc/fstab
UUID=F0B8596AB8592FF8 # troque pelo UUID do seu dispositivo 

# Função de log
log() {
    logger -t HDD_Mount "$1"
}

# Pega o dispositivo físico pelo UUID
DISPOSITIVO=$(blkid -U "$UUID")

if [ -z "$DISPOSITIVO" ]; then
    log "UUID $UUID não encontrado no sistema."
    exit 1
fi

# Obtém o mountpoint correto do /etc/fstab
MOUNTPOINT_CORRETO=$(grep "UUID=$UUID" /etc/fstab | awk '{print $2}')

if [ -z "$MOUNTPOINT_CORRETO" ]; then
    log "UUID $UUID não possui entrada válida no /etc/fstab."
    exit 1
fi

# Cria o diretório se não existir
[ ! -d "$MOUNTPOINT_CORRETO" ] && mkdir -p "$MOUNTPOINT_CORRETO"

# Verifica onde está montado atualmente
MONTADO_ATUAL=$(lsblk -o UUID,MOUNTPOINT -nr | grep "$UUID" | awk '{print $2}')

# Caso já esteja correto
if [ "$MONTADO_ATUAL" == "$MOUNTPOINT_CORRETO" ]; then
    log "UUID $UUID já está montado corretamente em $MOUNTPOINT_CORRETO."
    exit 0
fi

# Caso esteja montado no lugar errado
if [ -n "$MONTADO_ATUAL" ]; then
    log "UUID $UUID está montado incorretamente em $MONTADO_ATUAL. Desmontando..."
    umount "$DISPOSITIVO"
    sleep 1
fi

# Tenta montar no local correto conforme fstab
log "Montando UUID $UUID em $MOUNTPOINT_CORRETO..."
mount "$MOUNTPOINT_CORRETO"

if [ $? -eq 0 ]; then
    log "UUID $UUID montado com sucesso em $MOUNTPOINT_CORRETO."
else
    log "Falha ao montar UUID $UUID em $MOUNTPOINT_CORRETO."
    exit 1
fi
