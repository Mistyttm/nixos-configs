{ ... }:
{
  networking.wireguard.enable = true;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/root/wireguard-keys/private";

    peers = [
      {
        # Your home server
        publicKey = "PV35fOdFKVsftJ7lh+xVTYxDY9fw4mgN9hwlrDOnzlk=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
