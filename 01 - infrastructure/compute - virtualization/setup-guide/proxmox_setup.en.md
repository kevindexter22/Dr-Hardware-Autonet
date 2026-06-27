<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/proxmox_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🛠️ (SOP) Bare-Metal Setup - Proxmox VE

### 📝 Description and Scope

This document is the Standard Operating Procedure (SOP) to install the Proxmox VE Hypervisor.

The goal is to install the operating system (OS) and prepare the hardware to run systems in KVM and LXC (Linux Containers). We will optimize some settings and fix the repositories (because we are using the free version). We will set a static IP to manage the server easily. We will also set a second disk for storage to keep ISOs, container images, and backups.

##

###  📋 Phase 1: Logic Architecture and Setup Strategy

First, we need to understand our hardware and how to use it. This prevents future problems.

In this project, I will use an old laptop, an HP Pavilion G4-2170br. This laptop has an Intel Core i5 3210M 2.50 GHz (3rd gen) processor, 8 GB DDR3 1600 MHz RAM, one 480 GB Kingston SSD, and one 750 GB HDD.

Because the hardware is limited, we will use these rules:

- **Virtualization (LXC vs KVM):** Proxmox uses LXC (Linux Containers) and KVM (Virtual Machines). Because my hardware is limited, I will use LXC more. LXC shares the host kernel and uses less RAM and CPU than KVM. I will use KVM only for systems that are not Linux (like Windows or BSD).
  
- **Storage Setup:**
   - 480 GB SSD (Tier 1): This will keep the OS (Proxmox) and the virtual disks of VMs/Containers (LVM-Thin). Fast read and write speed is very important for the system.
   - 750 GB HDD (Tier 2): This will be a storage folder for simple files: install ISOs, container templates, and Backups. This is a basic strategy to save your data if the SSD fails. 

- **File System:** Proxmox works with EXT4, ZFS, or BTRFS. Because my hardware is simple, I will use EXT4.<br>This is a homelab. I choose speed, low disk latency, and free RAM (EXT4 + LVM-Thin) instead of ZFS/Btrfs advanced data protection. I will stop data loss with a backup routine to the second HDD.

##

### 💾 Phase 2: Physical Prep and Installation (Host OS)

#### A. BIOS/UEFI Setup

Before you start, open the computer BIOS and check:

1. Virtualization Technology (VT-x) must be Enabled. Without this, KVM will not work.
2. Boot Order: Put the Proxmox VE USB drive as the first option.

#### B. Install Settings (Proxmox Installer)

When you start the OS installer, choose these settings:

1. **Target Hard Disk:** Choose the correct disk for the system. Example: 480 GB SSD.
2. **Options (Filesystem):** Click options and make sure the file system is EXT4.
3. **Network Setup:** Choose a static IP for the cable network (eth0/eno1) and a hostname. *Note: Do not use Wi-Fi for the hypervisor. Cables give better speed and ping.* 

##

### 🚀 Phase 3: Post-Install Tweaks (Tuning)

After the first boot, open the web interface (https://<PROXMOX_IP>:8006). Then, open the node shell to change settings.

#### A. Fix Repositories and Basic Settings

We do not have an enterprise license. We will change the enterprise repository so we do not get update errors. I will also turn off some tools I do not need right now.

1. I will use a PVE Post-Install script from <a href="https://community-scripts.org/">community-scripts.org</a>.
2.  To run this script, copy this command into the Proxmox shell:
   ```bash
   bash -c "$(curl -fsSL [https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh](https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh))"
```
  - After you run this command, it will ask some questions: if you want to run the script, if you want to turn off the          enterprise repository, if you want to turn on a free repository, and if you want to turn off HA (if you have only one         server, you can turn it off). At the end, it will update and ask to restart the server.<br>
  <br>⚠️ Note: Before you run scripts from the internet, always read the code to see if it is safe.  
  <br>I checked this script and it is safe, so I used it for this setup.

#### B. Setup 750 GB HDD (Tier 2 storage)

1. Find the disk (usually /dev/sdb):
   ```bash
   lsblk
    ```
2. Format it and make a folder:
   ```bash
   mkfs.ext4 /dev/sdb
   mkdir -p /mnt/hdd750
   ```
3. Add to fstab to mount automatically when you start the server:
   ```bash
   echo "/dev/sdb /mnt/hdd750 ext4 defaults 0 2" >> /etc/fstab
   mount -a
   ```
4. Go to the Proxmox Web Interface: Datacenter > Storage > Add > Directory
   - ID: Storage-HDD
   - Directory: /mnt/hdd750
   - Content: Choose VZDump backup file, ISO image, Container template

#### C. Virtual Memory Tweak (Swappiness)

To protect the SSD health and keep the system fast when RAM is low, we will make the system use less Swap memory:

1. Type this in the Proxmox shell:
   ```bash
    sysctl vm.swappiness=10
2. To save this change permanently, use this command:
   ```bash
   echo "vm.swappiness=10" >> /etc/sysctl.conf
   ```

#### D. Disable Laptop Sleep Mode

Laptops sleep when you close the lid. For a server, this is bad because the server stops working (Downtime).

To stop this sleep mode, we do this:

1. Edit the logind file:
   ```bash
   nano /etc/systemd/logind.conf
   ```
2. Remove the # and change this line:
   ```bash
   HandleLidSwitch=ignore
   ```
3. Restart the service:
   ```bash
   systemctl restart systemd-logind.service
   ```

##

### ⚙️ Phase 4: Operations Management

- **Fail Management (Backups):** Make a Backup Job in Proxmox (Datacenter > Backups) to create weekly snapshots of your important KVM/LXC. Put the destination strictly in Storage-HDD.

- **Performance Management:** Watch the Memory Ballooning in the Node Summary tab. Keep the global RAM use under 85% (about 6.8 GB). This stops the Linux OOM Killer (Out of Memory) from closing your services. We can also use observability tools to do this automatically.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license
