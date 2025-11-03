# Pre-Deployment Checklist

Use this checklist before deploying the MicroVM configuration.

## Planning Phase
- [ ] Read SUMMARY.md completely
- [ ] Read MIGRATION.md completely  
- [ ] Read README.md completely
- [ ] Understand the architecture and what will change
- [ ] Schedule maintenance window (expect 1-4 hours)
- [ ] Notify users of downtime
- [ ] Have console/physical access ready

## Preparation
- [ ] Identify network interface name: `ip addr show`
- [ ] Update `microvms/default.nix` with correct interface name
- [ ] Create `/backup/pre-microvm-migration` directory
- [ ] Backup all databases (especially PostgreSQL)
- [ ] Backup all service data directories
- [ ] Backup ACME certificates
- [ ] Backup current NixOS configuration
- [ ] Document current service states
- [ ] Test configuration build: `nixos-rebuild build`
- [ ] Review build output for errors

## Pre-Deployment Verification
- [ ] Flake inputs updated: `nix flake update`
- [ ] Configuration builds successfully
- [ ] No syntax errors in new configuration files
- [ ] Network interface name is correct
- [ ] Understand rollback procedure
- [ ] Have backups verified and accessible

## Migration Execution
- [ ] Create MicroVM directories: `/var/lib/microvms/*`
- [ ] Copy SOPS keys to VM secret directories
- [ ] Stop all services that will be migrated
- [ ] Take final live backups
- [ ] Deploy: `nixos-rebuild switch`
- [ ] Verify base system (bridge, NAT, iptables)
- [ ] Create VM volume images
- [ ] Format volume images with ext4
- [ ] Mount and copy data to volumes
- [ ] Start Web VM first
- [ ] Test Web VM
- [ ] Start remaining VMs one by one
- [ ] Test each VM as it starts

## Post-Deployment Testing
- [ ] All VMs show as running: `systemctl status 'microvm@*'`
- [ ] Matrix: Test Synapse API
- [ ] Matrix: Test federation
- [ ] Matrix: Test Discord bridge
- [ ] Matrix: Test TURN/STUN
- [ ] Web: Test HTTPS access
- [ ] Web: Test personal site
- [ ] Minecraft: Test server connection
- [ ] Gaming: Test Satisfactory connection
- [ ] Gaming: Test Valheim connection
- [ ] Network: Verify all port forwards work
- [ ] Network: Test from external network
- [ ] Logs: Check all VM logs for errors

## Stability Testing
- [ ] Let system run for 24 hours
- [ ] Monitor resource usage
- [ ] Monitor VM stability
- [ ] Test service restarts
- [ ] Test host reboot (VMs auto-start)
- [ ] Verify backups still work
- [ ] Test emergency shutdown/startup

## Finalization
- [ ] Enable monitoring (if applicable)
- [ ] Update documentation with any changes
- [ ] Document any issues encountered
- [ ] Notify users services are back online
- [ ] Schedule follow-up check in 1 week
- [ ] Consider cleanup of old data (after 1+ week)

## Emergency Contacts / Resources
- Rollback command: `sudo nixos-rebuild switch --rollback`
- Bootloader: Previous generation available in GRUB
- Documentation: 
  - SUMMARY.md
  - MIGRATION.md  
  - README.md
- Backup location: `/backup/pre-microvm-migration/`
- microvm.nix docs: https://microvm-nix.github.io/microvm.nix/

## Notes Section
Use this space to document your specific setup details:

**Network Interface**: _____________

**Deployment Date**: _____________

**Issues Encountered**:
- 
- 
- 

**Solutions Applied**:
- 
- 
- 

**Performance Notes**:
- 
- 
- 

**Follow-up Tasks**:
- [ ] 
- [ ] 
- [ ] 
