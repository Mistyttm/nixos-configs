# Migration Guide: Moving TheDogPark Services to MicroVMs

This guide will help you safely migrate your existing services to the new MicroVM-based architecture.

## ⚠️ IMPORTANT: Pre-Migration Checklist

Before starting, ensure you have:
- [ ] Full backup of `/var/lib/postgresql`
- [ ] Full backup of `/var/lib/matrix-synapse`
- [ ] Full backup of `/var/lib/minecraft-servers` or wherever Minecraft data is stored
- [ ] Full backup of `/var/lib/steamuser` (Satisfactory server)
- [ ] Full backup of `/srv/valheim`
- [ ] Full backup of `/var/lib/acme` (ACME certificates)
- [ ] Copy of `/home/misty/Documents/mistyttmpersonalsite`
- [ ] Access to your SOPS encryption keys
- [ ] Console/physical access to the server (in case network config breaks)

## Migration Strategy

We'll use a **staged migration** approach, testing each VM before moving to the next:

1. Matrix services (most complex)
2. Web services (critical for external access)
3. Minecraft server
4. Gaming servers (least critical)

## Step 0: Preparation (DO THIS FIRST!)

### 0.1 Find Your Network Interface
Check your actual external network interface name:
```bash
ip addr show
# Look for the interface with your public/external IP
# Common names: eth0, ens3, enp0s3, etc.
```

Update `hosts/thedogpark/microvms/default.nix`:
```nix
externalInterface = "YOUR_INTERFACE_NAME"; # Change from "ens3"
```

### 0.2 Backup Everything
```bash
# Create backup directory
sudo mkdir -p /backup/pre-microvm-migration

# Backup databases
sudo -u postgres pg_dumpall > /backup/pre-microvm-migration/postgres-all.sql

# Backup Matrix data
sudo tar czf /backup/pre-microvm-migration/matrix-synapse.tar.gz /var/lib/matrix-synapse

# Backup Minecraft
sudo tar czf /backup/pre-microvm-migration/minecraft.tar.gz /var/lib/minecraft-servers

# Backup Satisfactory
sudo tar czf /backup/pre-microvm-migration/satisfactory.tar.gz /var/lib/steamuser

# Backup Valheim
sudo tar czf /backup/pre-microvm-migration/valheim.tar.gz /srv/valheim

# Backup ACME
sudo tar czf /backup/pre-microvm-migration/acme.tar.gz /var/lib/acme
```

### 0.3 Document Current State
```bash
# Save running service list
systemctl list-units --state=running > /backup/pre-microvm-migration/services.txt

# Save network configuration
ip addr > /backup/pre-microvm-migration/network.txt
ip route > /backup/pre-microvm-migration/routes.txt
sudo iptables -L -n -v > /backup/pre-microvm-migration/iptables.txt
```

## Step 1: Build and Test (Don't Deploy Yet!)

### 1.1 Update flake inputs
```bash
cd /home/misty/Documents/nixos-configs-main
nix flake update
```

### 1.2 Build the new configuration (without switching)
```bash
sudo nixos-rebuild build --flake .#thedogpark
```

If this fails, fix errors before proceeding. Common issues:
- Missing dependencies
- Syntax errors in nix files
- Path issues

### 1.3 Review the changes
```bash
# See what will change
nix store diff-closures /run/current-system ./result
```

## Step 2: Prepare MicroVM Infrastructure

### 2.1 Create directory structure
```bash
sudo mkdir -p /var/lib/microvms/{matrix,minecraft,web,gaming}
sudo mkdir -p /var/lib/microvms/matrix/secrets
sudo mkdir -p /var/lib/microvms/web/secrets
```

### 2.2 Copy SOPS keys
```bash
# Copy age key for Matrix VM
sudo cp /var/lib/sops-nix/key.txt /var/lib/microvms/matrix/secrets/

# Copy age key for Web VM
sudo cp /var/lib/sops-nix/key.txt /var/lib/microvms/web/secrets/
```

### 2.3 Prepare Valheim directory (if not exists)
```bash
sudo mkdir -p /srv/valheim
# If Valheim data is elsewhere, move it:
# sudo mv /path/to/valheim/data/* /srv/valheim/
```

## Step 3: Deploy MicroVMs (Point of No Return!)

### 3.1 Stop all services that will be migrated
```bash
# Stop Matrix services
sudo systemctl stop matrix-synapse
sudo systemctl stop mautrix-discord
sudo systemctl stop coturn

# Stop web services
sudo systemctl stop nginx
sudo systemctl stop mistyttmpersonalsite

# Stop game servers
sudo systemctl stop minecraft-server-skyship  # or whatever it's called
sudo systemctl stop satisfactory-server
sudo systemctl stop valheimserver

# Don't stop postgresql yet - we'll migrate its data
```

### 3.2 Backup live data one more time
```bash
sudo -u postgres pg_dumpall > /backup/pre-microvm-migration/postgres-live.sql
```

### 3.3 Deploy the new configuration
```bash
sudo nixos-rebuild switch --flake .#thedogpark
```

This will:
- Install microvm.nix
- Create the microvm bridge network
- Configure NAT and firewall rules
- **NOT YET** start the VMs (they need data first)

### 3.4 Verify base system
```bash
# Check bridge interface
ip addr show microvm  # Should show 10.0.0.1/24

# Check NAT is configured
sudo iptables -t nat -L -n -v | grep DNAT

# Check systemd units exist
systemctl list-unit-files | grep microvm
```

## Step 4: Migrate Data to MicroVMs

### 4.1 Create VM volumes manually

**Note**: Sizes optimized for 75GB VPS

```bash
# Create all volume images (total ~70GB)
sudo truncate -s 10G /var/lib/microvms/matrix/postgres.img      # Reduced from 20GB
sudo truncate -s 5G /var/lib/microvms/matrix/synapse.img        # Reduced from 10GB
sudo truncate -s 20G /var/lib/microvms/minecraft/worlds.img     # Reduced from 50GB
sudo truncate -s 1G /var/lib/microvms/web/acme.img
sudo truncate -s 1G /var/lib/microvms/web/nginx.img
sudo truncate -s 30G /var/lib/microvms/gaming/steamuser.img     # Reduced from 100GB

# Format them with ext4
sudo mkfs.ext4 /var/lib/microvms/matrix/postgres.img
sudo mkfs.ext4 /var/lib/microvms/matrix/synapse.img
sudo mkfs.ext4 /var/lib/microvms/minecraft/worlds.img
sudo mkfs.ext4 /var/lib/microvms/web/acme.img
sudo mkfs.ext4 /var/lib/microvms/web/nginx.img
sudo mkfs.ext4 /var/lib/microvms/gaming/steamuser.img
```

### 4.2 Mount and copy data

#### Matrix VM data:
```bash
# Mount postgres image
sudo mkdir -p /mnt/temp-postgres
sudo mount /var/lib/microvms/matrix/postgres.img /mnt/temp-postgres

# Copy PostgreSQL data (if you want to preserve instead of recreating)
# sudo cp -a /var/lib/postgresql/* /mnt/temp-postgres/
# OR initialize empty and restore from backup later (recommended)
sudo mkdir -p /mnt/temp-postgres/16/data
sudo chown -R 999:999 /mnt/temp-postgres  # postgres UID in VM

sudo umount /mnt/temp-postgres

# Mount synapse image
sudo mkdir -p /mnt/temp-synapse
sudo mount /var/lib/microvms/matrix/synapse.img /mnt/temp-synapse

# Copy Matrix Synapse data
sudo cp -a /var/lib/matrix-synapse/* /mnt/temp-synapse/

sudo umount /mnt/temp-synapse
```

#### Minecraft VM data:
```bash
sudo mkdir -p /mnt/temp-minecraft
sudo mount /var/lib/microvms/minecraft/worlds.img /mnt/temp-minecraft

# Copy Minecraft server data
sudo cp -a /var/lib/minecraft-servers/* /mnt/temp-minecraft/

sudo umount /mnt/temp-minecraft
```

#### Web VM data:
```bash
sudo mkdir -p /mnt/temp-acme
sudo mount /var/lib/microvms/web/acme.img /mnt/temp-acme

# Copy ACME certificates
sudo cp -a /var/lib/acme/* /mnt/temp-acme/

sudo umount /mnt/temp-acme
```

#### Gaming VM data:
```bash
sudo mkdir -p /mnt/temp-gaming
sudo mount /var/lib/microvms/gaming/steamuser.img /mnt/temp-gaming

# Copy Satisfactory data
sudo cp -a /var/lib/steamuser/* /mnt/temp-gaming/

sudo umount /mnt/temp-gaming
```

## Step 5: Start MicroVMs

### 5.1 Start VMs one by one

#### Start Web VM first (least complex):
```bash
sudo systemctl start microvm@web

# Watch logs
sudo journalctl -u microvm@web -f

# Wait for it to fully boot (look for "Reached target Multi-User System")

# Test from host
curl http://10.0.0.4

# Test from outside (if port forwarding works)
curl http://your-server-ip
```

#### Start Minecraft VM:
```bash
sudo systemctl start microvm@minecraft

# Watch logs
sudo journalctl -u microvm@minecraft -f

# Test connection
nc -zv 10.0.0.3 25565
```

#### Start Gaming VM:
```bash
sudo systemctl start microvm@gaming

# Watch logs
sudo journalctl -u microvm@gaming -f
```

#### Start Matrix VM (most complex):
```bash
sudo systemctl start microvm@matrix

# Watch logs
sudo journalctl -u microvm@matrix -f

# Inside the VM, restore PostgreSQL if needed:
# You may need to exec into the VM or set up SSH
```

### 5.2 Verify all VMs are running
```bash
systemctl status 'microvm@*'
```

## Step 6: Post-Migration Testing

### 6.1 Test Matrix
```bash
# Test Synapse
curl http://10.0.0.2:8008/_matrix/client/versions

# Test from outside
curl https://mistyttm.dev/_matrix/client/versions
```

### 6.2 Test Web Services
```bash
# Test nginx
curl http://your-server-ip
curl https://mistyttm.dev

# Test personal site
curl http://10.0.0.4:8080
```

### 6.3 Test Minecraft
```bash
# Try connecting from Minecraft client
# Or use: nc -zv your-server-ip 25565
```

### 6.4 Test Gaming Servers
```bash
# Try connecting to Satisfactory
# Try connecting to Valheim
```

## Step 7: Enable Autostart

If everything works, enable autostart:
```bash
# This should already be configured in default.nix
# Verify:
sudo systemctl is-enabled microvm@matrix
sudo systemctl is-enabled microvm@minecraft
sudo systemctl is-enabled microvm@web
sudo systemctl is-enabled microvm@gaming
```

Reboot and verify all VMs start automatically:
```bash
sudo reboot

# After reboot:
systemctl status 'microvm@*'
```

## Rollback Plan

If something goes wrong, you can rollback:

### Option 1: Quick rollback (if system is still bootable)
```bash
# Switch back to previous generation
sudo nixos-rebuild switch --rollback

# Restore services
sudo systemctl start matrix-synapse
sudo systemctl start nginx
# etc...
```

### Option 2: Full rollback (if you kept old config)
```bash
# Comment out the microvm import in configuration.nix
# Uncomment the old service imports
sudo nixos-rebuild switch --flake .#thedogpark

# Restore data from backups if needed
```

### Option 3: Boot previous generation from bootloader
1. Reboot
2. Select previous generation from GRUB menu
3. System returns to pre-microvm state

## Troubleshooting Common Issues

### VMs won't start
```bash
# Check volume images exist
ls -lh /var/lib/microvms/*/

# Check permissions
sudo chown -R root:root /var/lib/microvms

# Check logs
sudo journalctl -u microvm@matrix -n 100
```

### Network not working
```bash
# Verify bridge
ip addr show microvm

# Verify NAT
sudo iptables -t nat -L -n -v

# Ping VMs from host
ping 10.0.0.2
ping 10.0.0.3
```

### Services not accessible from outside
```bash
# Check firewall
sudo iptables -L -n -v

# Check port forwarding
sudo iptables -t nat -L PREROUTING -n -v

# Test from inside VMs
# (need SSH access to VMs)
```

### Database issues in Matrix VM
```bash
# May need to restore from backup
# Access the VM and run:
sudo -u postgres psql < /path/to/backup.sql
```

## Post-Migration Cleanup

Once everything is working for at least a week:

```bash
# Remove old service data (AFTER CONFIRMING VMs WORK!)
# sudo rm -rf /var/lib/postgresql-old  # rename first, don't delete immediately
# sudo rm -rf /var/lib/matrix-synapse-old
# etc...
```

## Additional Resources

- [MicroVM README](./README.md) - Day-to-day management
- [microvm.nix docs](https://microvm-nix.github.io/microvm.nix/)
- Your backup directory: `/backup/pre-microvm-migration/`
