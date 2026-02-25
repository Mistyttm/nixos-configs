{ ... }:
{
  networking.wireguard.enable = true;

  # Wait for network (and DNS) to be fully online before starting,
  # otherwise the hostname endpoint fails to resolve and no peers get configured.
  systemd.services.wireguard-wg0 = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.3/24" ];
    privateKeyFile = "/root/wireguard-keys/private";

    peers = [
      {
        # thedogpark VPS - the VPN hub
        publicKey = "azW44KgfL9wjmY/XMlO8vhKUuJVomRB5U6PtGYJYlg8=";
        endpoint = "mistyttm.dev:51820";
        allowedIPs = [ "10.100.0.0/24" ];
        persistentKeepalive = 25;
        # Re-resolve the hostname endpoint periodically so transient DNS
        # failures during boot/rebuild don't permanently break the tunnel.
        dynamicEndpointRefreshSeconds = 30;
      }
    ];
  };
}
