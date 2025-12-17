{ ... }:
{
  networking.wireguard.enable = true;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];
    privateKeyFile = "/root/wireguard-keys/private";

    peers = [
      {
        publicKey = "azW44KgfL9wjmY/XMlO8vhKUuJVomRB5U6PtGYJYlg8=";
        endpoint = "mistyttm.dev:51820";
        allowedIPs = [ "10.100.0.1/32" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
