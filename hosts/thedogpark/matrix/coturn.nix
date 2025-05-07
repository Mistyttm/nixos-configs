{ config }: {
  sops.secrets."turn_secret" = {
    sopsFile = ../../../secrets/coturn.yaml;
    owner = "turnserver";
    group = "turnserver";
  };
  
  services.coturn = {
    enable = true;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets."turn_secret".path;
    realm = "mistyttm.dev";
    no-tcp-relay = true;
    cert = "/var/lib/acme/mistyttm.dev/fullchain.pem";
    pkey = "/var/lib/acme/mistyttmm.dev/key.pem";
    extraConfig=''
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255

      allowed-peer-ip=10.0.0.1

      user-quota=12
      total-quota=1200
    '';
  };
}