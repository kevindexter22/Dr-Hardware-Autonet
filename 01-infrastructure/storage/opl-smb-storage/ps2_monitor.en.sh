# ==============================================================================
# Workload: ps2_monitor.sh
# Architecture Domain: Network Core
# Author: Kevin Oliveira
# ==============================================================================

#!/bin/bash

# --- SETTINGS ---
OPL_PS2_IP="x.x.x.x"  # Replace with the IP you want to monitor
TAG="Monitor-Shutdown"   # Tag to filter in journalctl

# --- EXECUTION ---

# Try to ping 10 times to avoid false results from network problems
if ping -c 10 "$OPL_PS2_IP" > /dev/null 2>&1; then
    # If it responds, just log the message
    logger -t "$TAG" "INFO: The PS2 is ON. No action needed."
else
    # If it does NOT respond, log an alert and shut down the server
    logger -t "$TAG" "The PS2 is OFF or unreachable. Starting system shutdown..."
    
    # Command to shut down (requires root privileges)
    /sbin/shutdown -h now
fi
