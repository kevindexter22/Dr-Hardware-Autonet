# ==============================================================================
# Workload: hdd_mount_script
# Architecture Domain: Network Core
# Author: Kevin Oliveira
# ==============================================================================

#!/bin/bash

# UUID from /etc/fstab
UUID=F0B8596AB8592FF8 # Replace with your device's UUID

# Log function
log() {
    logger -t HDD_Mount "$1"
}

# Get physical device by UUID
DEVICE=$(blkid -U "$UUID")

if [ -z "$DEVICE" ]; then
    log "UUID $UUID not found on the system."
    exit 1
fi

# Get the correct mountpoint from /etc/fstab
CORRECT_MOUNTPOINT=$(grep "UUID=$UUID" /etc/fstab | awk '{print $2}')

if [ -z "$CORRECT_MOUNTPOINT" ]; then
    log "UUID $UUID does not have a valid entry in /etc/fstab."
    exit 1
fi

# Create directory if it does not exist
[ ! -d "$CORRECT_MOUNTPOINT" ] && mkdir -p "$CORRECT_MOUNTPOINT"

# Check where it is currently mounted
CURRENT_MOUNT=$(lsblk -o UUID,MOUNTPOINT -nr | grep "$UUID" | awk '{print $2}')

# If it is already correct
if [ "$CURRENT_MOUNT" == "$CORRECT_MOUNTPOINT" ]; then
    log "UUID $UUID is already mounted correctly at $CORRECT_MOUNTPOINT."
    exit 0
fi

# If it is mounted in the wrong place
if [ -n "$CURRENT_MOUNT" ]; then
    log "UUID $UUID is mounted incorrectly at $CURRENT_MOUNT. Unmounting..."
    umount "$DEVICE"
    sleep 1
fi

# Try to mount in the correct place according to fstab
log "Mounting UUID $UUID at $CORRECT_MOUNTPOINT..."
mount "$CORRECT_MOUNTPOINT"

if [ $? -eq 0 ]; then
    log "UUID $UUID mounted successfully at $CORRECT_MOUNTPOINT."
else
    log "Failed to mount UUID $UUID at $CORRECT_MOUNTPOINT."
    exit 1
fi
