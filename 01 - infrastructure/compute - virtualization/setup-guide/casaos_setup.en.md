<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/casaos_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🛠️ (SOP) Installing CasaOS - Raspberry Pi

### 📝 Description and Scope

CasaOS is not a full operating system. It is a light container manager with a web interface (Dashboard). It uses Docker. It usually runs on Linux (like Debian or Ubuntu) on the ARM architecture of the Raspberry Pi.

The goal of this tool is to run basic services for daily use. This makes operation and maintenance easy. It has a simple web interface and an app store. You can install pre-configured docker-compose apps with a few clicks.

##

### ℹ️ Requirements

- A Raspberry Pi (Raspberry Pi 4 or 5 with at least 4 GB of RAM is best).
- Ubuntu Server installed and connected to the internet.
- Terminal (CLI) access via SSH.

##

### 🐧 Phase 1: System Preparation

1. Before you install any service, you need to update the operating system. You must get the latest security patches and repositories.

To do this, use this command:
```bash
sudo apt update; sudo apt upgrade -y
```
*(If the system asks to restart after the update, do it with sudo reboot and connect again).*

2. The CasaOS script needs the curl tool to download files. Ubuntu usually has it, but to be safe, run this command:
```bash
sudo apt install curl -y
```

##

### ⚙️ Phase 2: Installing CasaOS

The CasaOS team made a script to automate the installation.

It will install Docker (if you do not have it), configure the internal networks (bridges), and download the CasaOS containers.

To use it, run the command:
```bash
curl -fsSL https://get.casaos.io | sudo bash
```
*What will happen now: The terminal will show a progress screen. This process can take 2 to 10 minutes. It depends on your internet speed and your Raspberry Pi model. It is downloading the Docker engine and the system images.*

When the script finishes, it usually shows the access address in the terminal.

If you did not write it down, find the local IP of your Raspberry Pi using the command:
```bash
hostname -I
```
*You will see an address like 192.168.x.x or 10.x.x.x*

##

### 🖥️ Phase 3: Access the Dashboard and create an admin account

1. Open your computer browser (it must be on the same network as the Raspberry Pi) and type the address from the previous step:
```bash
http://192.168.x.x
```

2. The first time you visit the web page, CasaOS will show a welcome screen. It will ask you to create an admin account.

3. Click "GO" or "Create Account".

4. Choose a username and a strong password.

5. Done! You are on the main Dashboard. You can start installing apps from the "App Store" or load your docker-compose files.

<p align="center"><br>
<img src="https://github.com/user-attachments/assets/26740f42-99b4-4741-a320-99f2964b283c" alt="Dashboard" width="300"/>
</p>

##

### 💡 Post-Installation Tips

- **Static IP:** Because this is a server and you will use a web interface, set a static IP if you did not do it yet. You can do this in the Ubuntu Server settings or by reserving an IP address in your router.

- **External Storage:** If you plug an external HD or SSD into the Raspberry Pi USB, CasaOS has a native file manager. Format the disk in ext4 (Linux standard) or ExFAT for better compatibility and performance.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
