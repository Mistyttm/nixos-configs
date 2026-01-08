{
  config,
  lib,
  ...
}:
{
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
  };

  # Override to run in foreground mode (remove -d flag)
  # The default module uses Type=forking with -d which fails on this system
  systemd.services.sabnzbd = {
    serviceConfig = {
      ExecStart = lib.mkForce "${config.services.sabnzbd.package}/bin/sabnzbd -f ${config.services.sabnzbd.configFile}";
      Type = lib.mkForce "simple";
    };
  };
}
