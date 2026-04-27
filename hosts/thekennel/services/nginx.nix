{
  ...
}:
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

    virtualHosts."homepage-lan" = {
      listen = [
        {
          addr = "192.168.0.171";
          port = 8082;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };

    virtualHosts."homepage-wireguard" = {
      listen = [
        {
          addr = "10.100.0.2";
          port = 8082;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    8082
    8097
    8098
  ];
}
