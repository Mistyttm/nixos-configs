{ self, ... }:
{
  flake.nixosModules.nginx =
    {
      lib,
      config,
      ...
    }:
    let
      hostName = config.networking.hostName or "";

      profiles = {
        thekennel = {
          firewallPorts = [
            8082
            8097
            8098
          ];

          virtualHosts = {
            "jellyfin-internal" = {
              listen = [
                {
                  addr = "10.100.0.2";
                  port = 8097;
                }
              ];

              locations."/" = {
                proxyPass = "http://127.0.0.1:8096";
                proxyWebsockets = true;
                extraConfig = ''
                  proxy_buffering off;
                '';
              };
            };

            "homepage-lan" = {
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

            "homepage-wireguard" = {
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
        };

        thedogpark = {
          firewallPorts = [
            80
            443
            8448
          ];

          sopsSecrets = {
            "porkbun-api-key" = {
              sopsFile = self.secrets.porkbun;
            };
            "porkbun-secret-api-key" = {
              sopsFile = self.secrets.porkbun;
            };
          };

          acme = {
            acceptTerms = true;
            defaults.email = "contact@mistyttm.dev";
            certs = {
              "mistyttm.dev" = {
                group = "nginx";
                dnsProvider = "porkbun";
              };
              "jellyfin.mistyttm.dev" = {
                group = "nginx";
                dnsProvider = "porkbun";
              };
            };
          };

          virtualHosts = {
            "discord-media.mistyttm.dev" = {
              useACMEHost = "mistyttm.dev";
              forceSSL = true;

              locations."/" = {
                proxyPass = "http://localhost:${toString config.services.mautrix-discord.settings.appservice.port}";
                extraConfig = ''
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                '';
              };
            };

            "mistyttm.dev" = {
              forceSSL = true;
              useACMEHost = "mistyttm.dev";

              listen = [
                {
                  addr = "0.0.0.0";
                  port = 443;
                  ssl = true;
                }
                {
                  addr = "[::]";
                  port = 443;
                  ssl = true;
                }
                {
                  addr = "0.0.0.0";
                  port = 8448;
                  ssl = true;
                }
                {
                  addr = "[::]";
                  port = 8448;
                  ssl = true;
                }
              ];

              locations."/".proxyPass = "http://localhost:8080/";

              locations."~ ^(/_matrix|/_synapse/client)" = {
                proxyPass = "http://localhost:8008";
                extraConfig = ''
                  proxy_set_header X-Forwarded-For $remote_addr;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Host $host;
                  client_max_body_size 50M;
                  proxy_http_version 1.1;
                  proxy_read_timeout 300s;
                  proxy_send_timeout 300s;
                '';
              };

              locations."/.well-known/matrix/client" = {
                extraConfig = ''
                  return 200 '{"m.homeserver": {"base_url": "https://mistyttm.dev"}}';
                  default_type application/json;
                  add_header Access-Control-Allow-Origin *;
                '';
              };

              locations."/.well-known/matrix/server" = {
                extraConfig = ''
                  return 200 '{"m.server": "mistyttm.dev:443"}';
                  default_type application/json;
                  add_header Access-Control-Allow-Origin *;
                '';
              };
            };

            "jellyfin.mistyttm.dev" = {
              useACMEHost = "jellyfin.mistyttm.dev";
              forceSSL = true;

              locations."/" = {
                proxyPass = "http://10.100.0.2:8097";
                proxyWebsockets = true;
                extraConfig = ''
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;

                  proxy_buffering off;
                  proxy_set_header Range $http_range;
                  proxy_set_header If-Range $http_if_range;

                  add_header X-Frame-Options "SAMEORIGIN" always;
                  add_header X-Content-Type-Options "nosniff" always;
                  add_header X-XSS-Protection "1; mode=block" always;

                  client_max_body_size 0;
                '';
              };
            };
          };
        };
      };

      profile = profiles.${hostName} or null;

      cfg = config.doggate.nginx;
    in
    {
      options.doggate.nginx.enable = lib.mkEnableOption "Unified, host-profile-driven nginx configuration";

      config = lib.mkIf (cfg.enable && profile != null) {
        services.nginx = {
          enable = true;
          # recommendedProxySettings = true;
          recommendedTlsSettings = true;
          virtualHosts = profile.virtualHosts;
        };

        networking.firewall.allowedTCPPorts = profile.firewallPorts or [ ];

        sops.secrets = lib.mapAttrs (
          _: value:
          value
          // {
            owner = config.users.users.nginx.name;
            group = config.users.users.nginx.group;
          }
        ) (profile.sopsSecrets or { });

        security.acme =
          if profile != null && profile ? acme then
            profile.acme
            // {
              certs = lib.mapAttrs (
                _: cert:
                cert
                // {
                  credentialFiles = {
                    PORKBUN_API_KEY_FILE = config.sops.secrets."porkbun-api-key".path;
                    PORKBUN_SECRET_API_KEY_FILE = config.sops.secrets."porkbun-secret-api-key".path;
                  };
                }
              ) profile.acme.certs;
            }
          else
            { };
      };
    };
}
