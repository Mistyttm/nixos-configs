{ ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."jellyfin-internal" = {
      listen = [
        {
          addr = "10.100.0.2";
          port = 8097;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:8096"; # Your Jellyfin port
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8097 ];
}
