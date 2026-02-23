{ ... }:
{
  networking.wireguard.enable = true;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/root/wireguard-keys/private";

    peers = [
      {
        # thekennel - home server
        publicKey = "PV35fOdFKVsftJ7lh+xVTYxDY9fw4mgN9hwlrDOnzlk=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        # puppypc - home desktop
        publicKey = "3P03yC/x9XLleiWhb3KgiiF9Jei69eMOVOzaqczW5QQ=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
      {
        # mistylappytappy - laptop
        publicKey = "4gYkapXc0P9tYPMxkjAjcT4wL2kEQ7QXbCD18K0Vsx4=";
        allowedIPs = [ "10.100.0.4/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  # Allow WireGuard peers to forward traffic through the hub (wg0 acts as the VPN router).
  # Without this, NixOS's iptables FORWARD chain drops all peer-to-peer traffic
  # even though ip_forward is enabled.
  networking.firewall.trustedInterfaces = [ "wg0" ];
}
