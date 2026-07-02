<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/storage/casaos-local-storage/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 💾 CasaOS Local Storage: Disk Mount Watchdog

### 📝 Description and Scope
This folder has the "State Enforcer" script for external storage (USB drives) on CasaOS (Raspberry Pi). 

Desktop systems and web interfaces often "kidnap" external hard drives. They mount them in random folders (like `/media/root/`). This breaks Docker container volumes (`bind mounts`). The goal of this script is to act as a Watchdog. It checks if the disk is mounted in the correct place. If it is in the wrong place, the script fixes it automatically.

##

### ⚙️ How it Works (State Enforcement)

The `hdd_mount_script.sh` script does not change host settings. It just reads the current state and fixes problems:

1. **Hardware Check:** It uses `blkid` to see if the UUID is really connected to the USB port.

2. **Read the Truth:** It checks the `/etc/fstab` file to find the correct official *Mountpoint* for that disk.

3. **State Audit:** It compares the data with `lsblk`. If the system mounted the disk in the wrong place, the script does a forced `umount`.

4. **Apply State:** It mounts the disk in the correct folder using the official system rule (`mount <MOUNTPOINT>`).

5. **Logs (Syslog):** All actions, successes, or errors go to the system log using the tag `HDD_Mount`. You can find them using `journalctl`.

##

### 📋 Prerequisites

For this script to work, the disk must already have a valid line inside the `/etc/fstab` file of the machine. 

Example of a good FSTAB line:

```text
UUID=F0B8596AB8592FF8 /mnt/storage_externo auto defaults,nofail 0 2
```

* **Note:** *The nofail option is very important. It makes sure the Raspberry Pi can still boot normally if you disconnect the     USB drive.*

##

### 🚀 Manual Test and Execution

To run the script and see the execution logs:

```bash
chmod +x mount-external-disk.sh
sudo ./mount-external-disk.sh

# To see the logs created by the script:
sudo journalctl -t HDD_Mount
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
