<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/raspberry_pi_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🛠️ (SOP) Bare-Metal Provisioning - Raspberry Pi

### 📝 Description and Scope

This document defines the Standard Operating Procedure (SOP) for the first setup of processing nodes based on ARM architecture (Raspberry Pi). 

The goal is to prepare the base Operating System image (Ubuntu Server or Raspberry Pi OS) manually (without needing a local monitor or keyboard). We inject L2/L3 network settings and remote access credentials (via *Cloud-Init*) directly into the physical storage (Micro-SD). This prepares the node for future integration and automated management via *Infrastructure as Code* (IaC) or for native service installation.

---

### 💾 Phase 1: Physical Media Preparation (Layer 1 / L1)

To ensure data block integrity and avoid errors on previously used cards in the infrastructure, we format the Micro-SD card using the **Raspberry Pi Imager** tool.

#### 1. Clearing the Partition Table
1. Open the Raspberry Pi Imager.
2. Under **CHOOSE DEVICE**, select your hardware model (e.g., Raspberry Pi 3B).
3. Under **OPERATING SYSTEM**, select the format option **ERASE** (MS-DOS FAT32).
4. Under **CHOOSE STORAGE**, select your Micro-SD drive.
5. Run the erase process by confirming **YES** in the warning window.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9f28cb4e-450e-4235-8563-23947dd24357" width="300" />
  <img src="https://github.com/user-attachments/assets/f7b0d48e-96ef-4998-937b-7725c7a10362" width="300" />
  <img src="https://github.com/user-attachments/assets/e7333177-5124-4592-985b-43d2de2c97f3" width="300" />
</p>

---

### 🐧 Phase 2: Base Operating System Installation (OS / NFVI)

The lab architecture uses **Ubuntu Server** as the standard because it is stable for network stacks and supports *Netplan* natively. However, this guide also works for **Raspberry Pi OS Lite**.

1. In the Raspberry Pi Imager, select the approved OS for your Resource Pool (e.g., *Other general-purpose OS > Ubuntu Server 24.04 LTS 64-bit* or *Raspberry Pi OS Lite 64-bit*).
2. Click **NEXT**.
3. In the install customization window, select **NO, CLEAR SETTINGS**. We will inject the metadata manually into the boot partition to have strict control over the network rules.
4. Confirm the write process and wait for the checksum validation and the end of the process.

<p align="center">
  <img src="https://github.com/user-attachments/assets/66009c77-24ba-4888-ac26-9b4696b6decb" width="300" />
  <img src="https://github.com/user-attachments/assets/602d52e8-3d5b-4d8e-8c34-36d658a9c557" width="300" />
</p>

---

### ⚙️ Phase 3: Configuration Injection via Cloud-Init (Layers 2 and 3)

For the Control Plane to manage the node remotely after boot, the device must join the correct broadcast domain and expose the SSH service (TCP/22). We will modify the mounted partition called `bootfs` (RPi OS) or `system-boot` (Ubuntu).

Remove and reinsert the Micro-SD card into the computer to mount the system partitions.

#### 1. Static IP and Uplink (Netplan / Network-Config)
Edit the `network-config` file. *Cloud-Init* reads this file on the first boot to configure the network interfaces.

Uncomment and adjust the settings for your uplink interface (`wlan0` for wireless or `eth0` for wired network), setting the routing and the static IP for the Management Plane:

<p align="center">
  <img src="https://github.com/user-attachments/assets/242187c5-5651-4171-85d5-efe24e809576" width="300" />
</p>

> **Architectural Note:** For Wi-Fi connections, make sure to enter the correct WPA keys in `access-points`.

#### 2. Identity and SecOps Configuration (RPi OS Only)
*Important: Ubuntu Server enables the SSH service by default (Default credentials: `ubuntu` / `ubuntu`). The steps below are strictly for the Raspberry Pi OS.*

1. **Enable SSH Daemon:** Create an empty file named `ssh` in the root of the boot partition.
```bash
touch /media/<your_user>/bootfs/ssh
```
2. **Inject Credentials and SHA-512 Hash:** Create the userconf.txt file to set up the system admin user and its encrypted password.

Generate the hash via shell (Linux/WSL):
```bash
echo "your_secure_password" | openssl passwd -6 -stdin
```

Add the output to the /media/<your_user>/bootfs/userconf.txt file using the key-value format user:hash:
```bash
admin_lab:$6$dU2DKSj1d8KE57Uy$Q.5BPFHoWNzupp7YQWbteJMt8/ANu...
```

---

### ✅ Phase 4: Validation and Handover (Post-Boot)

1. Safely eject the Micro-SD card, insert it into the Raspberry Pi hardware, and power on the device.

2. From your bastion host or management terminal, monitor network availability via ICMP (Layer 3):
```bash
ping <CONFIGURED_STATIC_IP>
```

3. Establish the initial encrypted tunnel to validate the host key (RSA/ED25519) and confirm the setup:
```bash
ssh <user>@<CONFIGURED_STATIC_IP>
```

Once authenticated, the Bare-Metal Bootstrap is complete. The node is now ready for the state transition, waiting for service deployment or continuous orchestration via Automation tools (e.g., Ansible/Terraform).

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
