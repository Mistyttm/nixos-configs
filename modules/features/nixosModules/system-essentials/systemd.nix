{ ... }:
{
  flake.nixosModules.systemd =
    {
      ...
    }:
    {
      # Reduce shutdown hang time — prevents stuck FUSE/portal processes from
      # blocking reboot indefinitely (default is 90s, which caused a hard lockup)
      systemd.settings.Manager.DefaultTimeoutStopSec = "30s";
      systemd.user.extraConfig = ''
        DefaultTimeoutStopSec=30s
      '';
    };
}
