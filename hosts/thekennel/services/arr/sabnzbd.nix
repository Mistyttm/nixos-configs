{
  config,
  lib,
  ...
}:
{
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # SABnzbd uses port 8085 by default, but the module only opens 8080
  networking.firewall.allowedTCPPorts = [ 8085 ];

  # Override to run in foreground mode (remove -d flag)
  # The default module uses Type=forking with -d which fails on this system
  systemd.services.sabnzbd = {
    serviceConfig = {
      ExecStart = lib.mkForce "${config.services.sabnzbd.package}/bin/sabnzbd -f ${config.services.sabnzbd.configFile}";
      Type = lib.mkForce "simple";
    };
  };
}
