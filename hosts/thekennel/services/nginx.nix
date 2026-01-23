{
  config,
  pkgs,
  lib,
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

    virtualHosts."heimdall-local" = lib.mkIf config.services.heimdall.enable {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8098;
        }
      ];

      root = "${config.services.heimdall.package}/share/heimdall/public";

      extraConfig = ''
        index index.php;
        charset utf-8;
        client_max_body_size 30M;
      '';

      locations."/" = {
        tryFiles = "$uri $uri/ /index.php?$query_string";
      };

      locations."~ \\.php$" = {
        extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.heimdall.socket};
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param PHP_VALUE "upload_max_filesize=30M \n post_max_size=30M";
        '';
      };

      locations."~ /\\.(?!well-known).*" = {
        return = "404";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    8097
    8098
  ];
}
