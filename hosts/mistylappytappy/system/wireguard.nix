{ ... }:
{
  networking.wireguard.enable = true;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.4/24" ];
    privateKeyFile = "/root/wireguard-keys/private";

    peers = [
      {
        # thedogpark VPS - the VPN hub
        publicKey = "azW44KgfL9wjmY/XMlO8vhKUuJVomRB5U6PtGYJYlg8=";
        endpoint = "mistyttm.dev:51820";
        allowedIPs = [ "10.100.0.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
