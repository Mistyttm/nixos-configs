# MicroVM Setup for TheDogPark

This directory contains the MicroVM configurations for separating services into isolated virtual machines.

## Overview

**Note**: This configuration is optimized for VPS constraints (75GB storage, 16GB RAM, 4 cores).
Only essential VMs auto-start. Gaming and Minecraft VMs are started manually as needed.

The services on TheDogPark have been compartmentalized into the following MicroVMs:

### 1. **matrix** (10.0.0.2) - Auto-starts
- Matrix Synapse homeserver
- Mautrix Discord bridge
- Coturn TURN/STUN server
- PostgreSQL databases
- **Resources**: 2GB RAM, 2 vCPUs
- **Storage**: 10GB for PostgreSQL, 5GB for Synapse data

### 2. **web** (10.0.0.4) - Auto-starts
- Nginx reverse proxy
- ACME/Let's Encrypt certificates
- Personal website (mistyttmpersonalsite)
- **Resources**: 1GB RAM, 1 vCPU
- **Storage**: 1GB for ACME, 1GB for nginx
- **Ports**: 80, 443, 8448 (Matrix federation)

### 3. **minecraft** (10.0.0.3) - Manual start
- Minecraft Fabric server (Skyship)
- **Resources**: 6GB RAM, 2 vCPUs
- **Storage**: 20GB for world data
- **Ports**: 25565 (TCP/UDP)

### 4. **gaming** (10.0.0.5) - Manual start
- Valheim dedicated server (Docker) - or -
- Satisfactory dedicated server
- **Note**: Runs ONE game at a time (currently Satisfactory by default)
- **Resources**: 8GB RAM, 2 vCPUs
- **Storage**: 30GB for Steam games
- **Ports**: 7777, 8888, 2456-2458

## Network Architecture

```
Host (thedogpark)
├─ Bridge: microvm (10.0.0.1/24)
│  ├─ matrix-vm (10.0.0.2)
│  ├─ minecraft-vm (10.0.0.3)
│  ├─ web-vm (10.0.0.4)
│  └─ gaming-vm (10.0.0.5)
└─ NAT to external interface (ens3)
```

All external traffic is forwarded from the host to the appropriate MicroVM via iptables rules defined in `default.nix`.

## File Structure

```
microvms/
├── default.nix      # Main configuration with VM declarations and networking
├── matrix.nix       # Matrix services VM configuration
├── minecraft.nix    # Minecraft server VM configuration
├── web.nix          # Web services VM configuration
└── gaming.nix       # Gaming servers VM configuration
```

## Initial Setup

### 1. Update your flake inputs
Run from the root of your nixos-configs:
```bash
nix flake update
```

### 2. Verify the configuration
```bash
nixos-rebuild build --flake .#thedogpark
```

### 3. Create necessary directories and secrets
Before deploying, ensure these directories exist on the host:
```bash
sudo mkdir -p /var/lib/microvms/{matrix,minecraft,web,gaming}/{secrets,}
sudo mkdir -p /srv/valheim
```

### 4. Copy SOPS keys to MicroVM secret directories
```bash
# For Matrix VM
sudo cp /var/lib/sops-nix/key.txt /var/lib/microvms/matrix/secrets/

# For Web VM (for ACME credentials)
sudo cp /var/lib/sops-nix/key.txt /var/lib/microvms/web/secrets/
```

### 5. Deploy the configuration
```bash
sudo nixos-rebuild switch --flake .#thedogpark
```

## Managing MicroVMs

### Managing Game Servers

The Gaming VM is configured to run **one game at a time** to conserve resources.

#### Using the Helper Script

A helper script is provided to easily switch between game servers:

```bash
# Check what's running
sudo ./microvms/gaming-switch.sh status

# Switch to Satisfactory (default)
sudo ./microvms/gaming-switch.sh satisfactory

# Switch to Valheim
sudo ./microvms/gaming-switch.sh valheim

# Stop all game servers and the VM
sudo ./microvms/gaming-switch.sh stop
```

#### Manual Management

```bash
# Start the gaming VM
sudo systemctl start microvm@gaming

# Check which game is running (Satisfactory auto-starts)
sudo journalctl -u microvm@gaming -f

# To switch games manually, you'd need to:
# 1. Access the VM (no SSH configured yet)
# 2. Stop one game: systemctl stop satisfactory-server
# 3. Start the other: systemctl start valheimserver
```

### Start/Stop VMs
```bash
# Start a specific VM (for manual-start VMs)
sudo systemctl start microvm@gaming
sudo systemctl start microvm@minecraft

# Stop a specific VM
sudo systemctl stop microvm@web

# Restart a VM
sudo systemctl restart microvm@matrix
```

### View VM status
```bash
# Check all MicroVMs
sudo systemctl status 'microvm@*'

# Check a specific VM
sudo systemctl status microvm@gaming
```

### View VM console/logs
```bash
# Follow logs for a specific VM
sudo journalctl -u microvm@matrix -f

# View recent logs
sudo journalctl -u microvm@web -n 100
```

### Update a MicroVM
```bash
# Using the microvm command (imperative updates)
sudo microvm -u matrix

# Or rebuild the entire system (declarative)
sudo nixos-rebuild switch --flake .#thedogpark
```

### Access VM console
MicroVMs run headless, but you can access them via:
```bash
# SSH into the VM (if SSH is configured)
ssh root@10.0.0.2  # Matrix VM
ssh root@10.0.0.3  # Minecraft VM
ssh root@10.0.0.4  # Web VM
ssh root@10.0.0.5  # Gaming VM
```

Note: You'll need to configure SSH in each VM and set up keys.

## Storage Management

### Volume locations
All VM volumes are stored in `/var/lib/microvms/<vm-name>/`:
```bash
/var/lib/microvms/
├── matrix/
│   ├── postgres.img (20GB)
│   └── synapse.img (10GB)
├── minecraft/
│   └── worlds.img (50GB)
├── web/
│   ├── acme.img (1GB)
│   └── nginx.img (1GB)
└── gaming/
    └── steamuser.img (100GB)
```

### Resize a volume
If you need more space:
1. Stop the VM: `sudo systemctl stop microvm@matrix`
2. Resize the image: `sudo truncate -s +10G /var/lib/microvms/matrix/postgres.img`
3. Start the VM: `sudo systemctl start microvm@matrix`
4. Inside the VM, resize the filesystem (depends on filesystem type)

## Troubleshooting

### VM won't start
Check logs:
```bash
sudo journalctl -u microvm@matrix -n 100
```

Common issues:
- Missing volumes: Check `/var/lib/microvms/<vm>/`
- Network conflicts: Ensure bridge interface is configured
- Resource limits: Check available memory/CPU

### Network connectivity issues
Verify bridge and NAT:
```bash
# Check bridge status
ip addr show microvm

# Check iptables rules
sudo iptables -t nat -L -n -v
```

### Can't reach services from outside
Verify port forwarding rules in `default.nix` are correct and applied:
```bash
sudo iptables -t nat -L PREROUTING -n -v
```

## Important Notes

### Before Making Changes
1. **Network Interface**: Update `externalInterface = "ens3"` in `default.nix` if your host uses a different network interface
2. **Secrets**: Ensure SOPS keys are properly copied to VM secret directories
3. **Permissions**: MicroVMs run as root but services inside run as dedicated users

### Shared Resources
- `/nix/store` is shared read-only (via virtiofs) to all VMs - this saves disk space
- ACME certificates are shared from host to Matrix VM for Coturn
- Personal website source is shared from host to Web VM

### Backup Strategy
Important data to backup:
- `/var/lib/microvms/*/` (all VM volumes)
- `/srv/valheim/` (Valheim server data)
- `/home/misty/Documents/mistyttmpersonalsite/` (if not in git)

## Future Improvements

Consider these enhancements:
1. Add SSH access to each VM for easier management
2. Set up centralized logging (forward all VM logs to host)
3. Add monitoring (Prometheus/Grafana) for VM resources
4. Configure automated backups of VM volumes
5. Add fail2ban to Web VM for additional security
6. Consider splitting Matrix services into separate VMs (Synapse, Bridge, Coturn)

## Resources

- [microvm.nix documentation](https://microvm-nix.github.io/microvm.nix/)
- [microvm.nix GitHub](https://github.com/microvm-nix/microvm.nix)
- NixOS Manual: [NixOS Containers](https://nixos.org/manual/nixos/stable/#ch-containers)
