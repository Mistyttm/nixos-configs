# MicroVM Quick Reference - VPS Optimized

## System Limits
- **Host**: 75GB storage, 16GB RAM, 4 CPU cores (VPS)
- **Configuration**: Only essential VMs auto-start

## VM Resource Allocation

| VM        | RAM | vCPU | Storage | IP       | Auto-start? |
| --------- | --- | ---- | ------- | -------- | ----------- |
| Matrix    | 2GB | 2    | 15GB    | 10.0.0.2 | ✅ Yes       |
| Web       | 1GB | 1    | 2GB     | 10.0.0.4 | ✅ Yes       |
| Minecraft | 6GB | 2    | 20GB    | 10.0.0.3 | ❌ Manual    |
| Gaming    | 8GB | 2    | 30GB    | 10.0.0.5 | ❌ Manual    |

**Active Load**: 3GB RAM (Matrix + Web only)
**With Gaming**: 11GB RAM (Matrix + Web + Gaming)
**With Minecraft**: 9GB RAM (Matrix + Web + Minecraft)

## Quick Commands

### Check Status
```bash
# All VMs
systemctl status 'microvm@*'

# Specific VM
systemctl status microvm@gaming
```

### Start/Stop VMs
```bash
# Start gaming VM
sudo systemctl start microvm@gaming

# Start minecraft VM
sudo systemctl start microvm@minecraft

# Stop gaming VM (frees 8GB RAM)
sudo systemctl stop microvm@gaming

# Restart web VM
sudo systemctl restart microvm@web
```

### Gaming Server Management

Use the helper script (recommended):
```bash
# Check what's running
sudo ./microvms/gaming-switch.sh status

# Start Satisfactory (stops Valheim if running)
sudo ./microvms/gaming-switch.sh satisfactory

# Start Valheim (stops Satisfactory if running)
sudo ./microvms/gaming-switch.sh valheim

# Stop all game servers
sudo ./microvms/gaming-switch.sh stop
```

### View Logs
```bash
# Follow logs
sudo journalctl -u microvm@gaming -f

# Recent logs
sudo journalctl -u microvm@matrix -n 50

# All microvm logs
sudo journalctl -u 'microvm@*' -f
```

## Resource Management Tips

### When running Minecraft:
1. Stop gaming VM: `sudo systemctl stop microvm@gaming`
2. Start minecraft VM: `sudo systemctl start microvm@minecraft`
3. RAM usage: 3GB (base) + 6GB (minecraft) = 9GB

### When running Satisfactory:
1. Stop minecraft if running: `sudo systemctl stop microvm@minecraft`
2. Start gaming VM: `sudo systemctl start microvm@gaming`
3. Satisfactory auto-starts
4. RAM usage: 3GB (base) + 8GB (gaming) = 11GB

### When running Valheim:
1. Stop minecraft if running: `sudo systemctl stop microvm@minecraft`
2. Use helper: `sudo ./microvms/gaming-switch.sh valheim`
3. RAM usage: 3GB (base) + 8GB (gaming) = 11GB

### To free maximum RAM:
```bash
sudo systemctl stop microvm@gaming
sudo systemctl stop microvm@minecraft
# Only Matrix + Web running = 3GB RAM used
```

## Storage Usage

```
Total: ~70GB (of 75GB available)

Matrix:     15GB (10GB postgres, 5GB synapse)
Minecraft:  20GB (world data)
Gaming:     30GB (Satisfactory + Valheim)
Web:         2GB (nginx + ACME)
System:     ~3GB (remaining space + overhead)
```

## Port Forwarding

| Service      | External Port | → VM        | VM Port |
| ------------ | ------------- | ----------- | ------- |
| HTTP         | 80            | → web       | 80      |
| HTTPS        | 443           | → web       | 443     |
| Matrix Fed   | 8448          | → web       | 8448    |
| Minecraft    | 25565         | → minecraft | 25565   |
| Satisfactory | 7777, 8888    | → gaming    | 7777    |
| Valheim      | 2456-2458     | → gaming    | 2456    |

## Auto-start on Boot

Only these VMs start automatically:
- ✅ Matrix (10.0.0.2)
- ✅ Web (10.0.0.4)

Start manually as needed:
- ❌ Minecraft (10.0.0.3)
- ❌ Gaming (10.0.0.5)

## Emergency Commands

```bash
# Stop all MicroVMs
sudo systemctl stop 'microvm@*'

# Restart all auto-start VMs
sudo systemctl restart 'microvm@*'

# Check resource usage
htop  # or top

# Check disk usage
df -h /var/lib/microvms

# Rebuild system
sudo nixos-rebuild switch --flake .#thedogpark

# Rollback
sudo nixos-rebuild switch --rollback
```

## Files

- `default.nix` - VM declarations & networking
- `matrix.nix` - Matrix services config
- `minecraft.nix` - Minecraft config
- `web.nix` - Web services config
- `gaming.nix` - Gaming servers config
- `gaming-switch.sh` - Game server helper script
- `README.md` - Full documentation
- `MIGRATION.md` - Migration guide
- `SUMMARY.md` - Architecture overview

## Quick Troubleshooting

**VM won't start**: Check logs with `sudo journalctl -u microvm@<name> -n 100`

**Out of RAM**: Stop unnecessary VMs (`sudo systemctl stop microvm@gaming`)

**Out of disk**: Check volume usage: `sudo du -sh /var/lib/microvms/*/`

**Network issues**: Verify bridge: `ip addr show microvm`

**Port not forwarding**: Check iptables: `sudo iptables -t nat -L -n -v`

## Support

- Full docs: `README.md`
- Migration: `MIGRATION.md`
- Overview: `SUMMARY.md`
- Online: https://microvm-nix.github.io/microvm.nix/
