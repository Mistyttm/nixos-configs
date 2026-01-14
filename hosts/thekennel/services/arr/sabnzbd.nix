{
  config,
  lib,
  ...
}:
let
  cfg = config.services.sabnzbd;
  sabnzbdIniPath = "/var/lib/${cfg.stateDir}/sabnzbd.ini";
in
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
      ExecStart = lib.mkForce "${cfg.package}/bin/sabnzbd -f ${sabnzbdIniPath} -s 0.0.0.0:8080";
      Type = lib.mkForce "simple";
    };
  };
}
