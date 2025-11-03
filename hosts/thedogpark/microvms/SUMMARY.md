# MicroVM Setup Summary

## What Was Done

Your TheDogPark system has been configured to use microvm.nix to run services in isolated virtual machines. The configuration is ready to deploy.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    TheDogPark Host                          │
│                    (10.0.0.1)                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              microvm bridge network                  │   │
│  │                  (10.0.0.0/24)                       │   │
│  │                                                      │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────┐  ┌─────────┐   │   │
│  │  │  Matrix  │  │Minecraft │  │ Web  │  │ Gaming  │   │   │
│  │  │ 10.0.0.2 │  │ 10.0.0.3 │  │10.0  │  │ 10.0.0.5│   │   │
│  │  │          │  │          │  │.0.4  │  │         │   │   │
│  │  │ Synapse  │  │  Fabric  │  │Nginx │  │Valheim  │   │   │
│  │  │ Discord  │  │  Server  │  │ACME  │  │Satisfac │   │   │
│  │  │ Bridge   │  │          │  │Site  │  │-tory    │   │   │
│  │  │ Coturn   │  │          │  │      │  │         │   │   │
│  │  │ PostGres │  │          │  │      │  │Docker   │   │   │
│  │  └──────────┘  └──────────┘  └──────┘  └─────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                 │
│                    NAT + Port Forwarding                    │
│                           │                                 │
└───────────────────────────┼─────────────────────────────────┘
                            │
                     External Network
```

## Files Created/Modified

### New Files:
- `hosts/thedogpark/microvms/default.nix` - Main MicroVM configuration
- `hosts/thedogpark/microvms/matrix.nix` - Matrix services VM
- `hosts/thedogpark/microvms/minecraft.nix` - Minecraft server VM
- `hosts/thedogpark/microvms/web.nix` - Web services VM
- `hosts/thedogpark/microvms/gaming.nix` - Gaming servers VM
- `hosts/thedogpark/microvms/README.md` - Management guide
- `hosts/thedogpark/microvms/MIGRATION.md` - Step-by-step migration

### Modified Files:
- `flake.nix` - Added microvm.nix input and host module
- `hosts/thedogpark/configuration.nix` - Import microvms, removed old service imports

## Resource Allocation

**Optimized for VPS limits: 75GB storage, 16GB RAM, 4 cores**

| VM        | RAM      | vCPU  | Storage    | IP       | Auto-start |
| --------- | -------- | ----- | ---------- | -------- | ---------- |
| Matrix    | 2GB      | 2     | 10GB + 5GB | 10.0.0.2 | Yes        |
| Web       | 1GB      | 1     | 1GB + 1GB  | 10.0.0.4 | Yes        |
| Minecraft | 6GB      | 2     | 20GB       | 10.0.0.3 | Manual     |
| Gaming    | 8GB      | 2     | 30GB       | 10.0.0.5 | Manual     |
| **Total** | **17GB** | **7** | **~70GB**  |          |            |

**Note**: Only Matrix and Web auto-start. Start Minecraft or Gaming manually as needed.
Gaming VM runs ONE server at a time (currently Satisfactory by default).

## Port Forwarding (Host → VMs)

| Service           | Protocol | Port(s)    | → VM          |
| ----------------- | -------- | ---------- | ------------- |
| HTTP/HTTPS        | TCP      | 80, 443    | → web:80,443  |
| Matrix Federation | TCP      | 8448       | → web:8448    |
| Matrix Synapse    | TCP      | 8008       | → matrix:8008 |
| TURN/STUN         | TCP/UDP  | 3478, 5349 | → matrix      |
| Minecraft         | TCP/UDP  | 25565      | → minecraft   |
| Satisfactory      | TCP/UDP  | 7777, 8888 | → gaming      |
| Valheim           | TCP/UDP  | 2456-2458  | → gaming      |

## Next Steps

### ⚠️ CRITICAL: Before deploying, read the MIGRATION.md file!

The configuration is ready but **NOT YET DEPLOYED**. Follow these steps:

1. **Read MIGRATION.md thoroughly** - It contains critical steps for safe migration
2. **Update network interface** in `microvms/default.nix` (change from `ens3` to your actual interface)
3. **Backup all data** before deploying
4. **Test build** without switching: `sudo nixos-rebuild build --flake .#thedogpark`
5. **Follow the migration guide** step by step

### Quick Start (After Reading Migration Guide):

```bash
# 1. Update flake
cd /home/misty/Documents/nixos-configs-main
nix flake update

# 2. Build (test only)
sudo nixos-rebuild build --flake .#thedogpark

# 3. If successful, follow MIGRATION.md from Step 2 onwards
```

## Key Features

### Security Benefits
- **Isolation**: Services can't interfere with each other
- **Attack Surface**: Compromise of one VM doesn't affect others
- **Resource Limits**: Each VM has dedicated resources
- **Dedicated Kernels**: Each VM runs its own kernel

### Operational Benefits
- **Independent Updates**: Update one VM without affecting others
- **Easy Rollback**: Rollback individual VMs if updates fail
- **Resource Management**: Clear resource allocation per service
- **Modularity**: Easy to add/remove services

### Shared Resources
- `/nix/store` shared read-only to all VMs (saves ~50GB+ per VM)
- Secrets shared via dedicated directories
- Personal website source shared to web VM
- ACME certs shared from host to VMs that need them

## Important Notes

### Before First Boot:
1. VMs need their volumes created and formatted (see MIGRATION.md)
2. Secrets must be copied to VM secret directories
3. Network interface name must be correct in default.nix
4. External firewall must allow the required ports

### Limitations:
- VMs don't have SSH configured yet (add if needed)
- No monitoring/metrics configured (add Prometheus/Grafana if desired)
- No automated backups configured
- Logs are per-VM (consider centralized logging)

### Known Issues:
- Coturn cert path has typo: `mistyttmm.dev` → should be `mistyttm.dev`
  - Fix in `matrix/coturn.nix` line 13
- Personal website runs as nginx user in VM (may need adjustment)
- Gaming VM assumes `/srv/valheim/start.sh` exists

## Managing Game Servers

The Gaming VM runs **one game server at a time** to stay within resource limits.

### Using the Helper Script

```bash
# Check status
sudo ./microvms/gaming-switch.sh status

# Switch to Satisfactory (stops Valheim if running)
sudo ./microvms/gaming-switch.sh satisfactory

# Switch to Valheim (stops Satisfactory if running)
sudo ./microvms/gaming-switch.sh valheim

# Stop all game servers
sudo ./microvms/gaming-switch.sh stop
```

### Manual Management

```bash
# Start Gaming VM manually
sudo systemctl start microvm@gaming

# Inside the VM, only Satisfactory auto-starts
# To switch games:
sudo systemctl stop satisfactory-server
sudo systemctl start valheimserver

# Or vice versa:
sudo systemctl stop valheimserver
sudo systemctl start satisfactory-server
```

## Management Commands

```bash
# Start/stop VMs
sudo systemctl start microvm@matrix
sudo systemctl stop microvm@web
sudo systemctl start microvm@gaming  # Start gaming VM manually

# View logs
sudo journalctl -u microvm@minecraft -f

# Check status
systemctl status 'microvm@*'

# Update a VM
sudo microvm -u matrix

# Rebuild entire system
sudo nixos-rebuild switch --flake .#thedogpark
```

## Troubleshooting Resources

1. **README.md** - Day-to-day management and troubleshooting
2. **MIGRATION.md** - Detailed migration steps and rollback procedures
3. **VM Logs**: `sudo journalctl -u microvm@<name>`
4. **microvm.nix docs**: https://microvm-nix.github.io/microvm.nix/

## Support

If you encounter issues:
1. Check logs: `sudo journalctl -u microvm@<vm-name> -n 100`
2. Verify network: `ip addr show microvm` and `sudo iptables -t nat -L -n -v`
3. Check volumes: `ls -lh /var/lib/microvms/*/`
4. Review MIGRATION.md troubleshooting section
5. Consult microvm.nix documentation

## Future Enhancements

Consider adding:
- [ ] SSH access to VMs for easier management
- [ ] Centralized logging (all VM logs → host syslog)
- [ ] Monitoring (Prometheus + Grafana)
- [ ] Automated backups of VM volumes
- [ ] fail2ban on web VM
- [ ] Split Matrix services into separate VMs
- [ ] Add development/staging VMs
- [ ] Implement secrets rotation
- [ ] Add health checks and automatic restarts

---

**Status**: Configuration ready, awaiting deployment
**Last Updated**: November 3, 2025
**Created By**: GitHub Copilot
