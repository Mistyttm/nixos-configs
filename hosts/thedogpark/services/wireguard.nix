{ ... }:
{
  networking.wireguard.enable = true;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/root/wireguard-private-key";

    peers = [
      {
        # Your home server
        publicKey = "SNAnn10zH9DRCAOFwcv7D9mIgxcnve0PqXhpRNCAyX4=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
