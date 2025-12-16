{ ... }:
{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];
    privateKeyFile = "/root/wireguard-private-key";

    peers = [
      {
        publicKey = "i4igg4Ozo2fXnWyFLxuVtpGjBH4ipJ1LfMcp5HSkP08=";
        endpoint = "mistyttm.dev:51820";
        allowedIPs = [ "10.100.0.1/32" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
