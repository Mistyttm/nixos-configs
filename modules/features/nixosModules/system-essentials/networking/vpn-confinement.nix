{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.vpn-confinement = {
    config,
    lib,
    ...
  }: {
    sops.secrets.protonvpn-wg-conf = {
      sopsFile = self.secrets.protonvpn;
      mode = "0400";
    };

    imports = [
      inputs.vpn-confinement.nixosModules.default
    ];

    vpnNamespaces.wg0 = {
      enable = true;
      wireguardConfigFile = config.sops.secrets.protonvpn-wg-conf.path;
      # LAN allowed to reach the confined services' WebUIs
      accessibleFrom = [
"192.168.0.0/24"

        "10.100.0.0/24"
      ];

      portMappings = [
        {
          from = 8080;
          to = 8080;
        } # qBittorrent WebUI
        {
          from = 9696;
          to = 9696;
        } # Prowlarr WebUI
      ];

      # torrent listening port, forwarded through the VPN itself
      openVPNPorts = [
        {
          port = 51413;
          protocol = "both";
        }
      ];
    };

    systemd.services.qbittorrent.vpnConfinement = lib.mkIf config.services.qbittorrent.enable {
      enable = true;
      vpnNamespace = "wg0";
    };
  };
}
