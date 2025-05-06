{ config, ... }: let 
  # discordBridgePort = toString config.services.mautrix-discord.settings.appservice.port;
in{
  networking.firewall.allowedTCPPorts = [
    80
    443
    8448
  ];


  sops.secrets."porkbun-api-key" = {
    sopsFile = ../../secrets/porkbun.yaml;
    owner = config.users.users.nginx.name;
    group = config.users.users.nginx.group;
  };

  sops.secrets."porkbun-secret-api-key" = {
    sopsFile = ../../secrets/porkbun.yaml;
    owner = config.users.users.nginx.name;
    group = config.users.users.nginx.group;
  };  

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@mistyttm.dev";
    certs."mistyttm.dev" = {
        group = "nginx";
        dnsProvider = "porkbun";
        credentialFiles = {
          PORKBUN_API_KEY_FILE = config.sops.secrets."porkbun-api-key".path;
          PORKBUN_SECRET_API_KEY_FILE = config.sops.secrets."porkbun-secret-api-key".path;
        };
    };
  };

  services.nginx.virtualHosts = let
    SSL = {
      enableACME = true;
      forceSSL = true;
    }; in {
      "minecraft.mistyttm.dev" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:25565/";
      });
      # "discord-media.mistyttm.dev" = {
      #   useACMEHost = "mistyttm.dev";
      #   forceSSL = true;

      #   locations."/" = {
      #     proxyPass = "http://localhost:${discordBridgePort}";
      #     extraConfig = ''
      #       proxy_set_header Host $host;
      #       proxy_set_header X-Real-IP $remote_addr;
      #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #       proxy_set_header X-Forwarded-Proto $scheme;
      #     '';
      #   };
      # };
      "mistyttm.dev" = {
        forceSSL = true;
        useACMEHost = "mistyttm.dev";

        listen = [
          { addr = "0.0.0.0"; port = 443; ssl = true; }
          { addr = "[::]"; port = 443; ssl = true; }
          { addr = "0.0.0.0"; pot = 8448; ssl = true; }
          { addr = "[::]"; port = 8448; ssl = true; }
        ];

        locations."/".proxyPass = "http://localhost:8080/";

        locations."~ ^(/_matrix|_synapse/client)" = {
          proxyPass = "http://localhost:8008";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host:$server_port;
            client_max_body_size 50M;
            proxy_http_version 1.1;
          '';
        };

        locations."/.well-known/matrix/client" = {
          extraConfig = ''
            return 200 '{"m.homeserver": {"base_url": "https://mistyttm.dev"}}';
            default_type application/json;
            add_header Access-Control-Allow-Origin *;
          '';
        };
      };
    };
}
