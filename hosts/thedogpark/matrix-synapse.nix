{ lib, config, ... }: let 
  maybeListener = lib.lists.findFirst (l: l.tls == false) null config.services.matrix-synapse.settings.listeners;
  synapsePort = if maybeListener == null then 8008 else maybeListener.port;
in {
  sops.secrets."registration_shared_secret" = {
    sopsFile = ../../secrets/synapse.yaml;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };
  sops.secrets."turn_shared_secret" = {
    sopsFile = ../../secrets/synapse.yaml;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };
  sops.secrets."turn_secret" = {
    sopsFile = ../../secrets/coturn.yaml;
    owner = "turnserver";
    group = "turnserver";
  };

  services.matrix-synapse = {
    enable =true;
    extras = [
      "cache-memory" # Provide statistics about caching memory consumption
      "jwt"          # JSON Web Token authentication
      "oidc"         # OpenID Connect authentication
      "postgres"     # PostgreSQL database backend
      "saml2"        # SAML2 authentication
      "sentry"       # Error tracking and performance metrics
      "systemd"      # Provide the JournalHandler used in the default log_config
      "url-preview"  # Support for oEmbed URL previews
      "user-search"  # Support internationalized domain names in user-search
    ];
    settings = {
      server_name = "mistyttm.dev";
      public_baseurl = "https://mistyttm.dev";
      email = {
        smtp_host = "mail.mistyttm.dev";
        smtp_port = 587;
        smtp_user = "noreply@mistyttm.dev";
        notif_from = "Misty TTM Matrix <noreply@mistyttm.dev>";
        require_transport_security = true;
      };
      registration_shared_secret_path = config.sops.secrets."registration_shared_secret".path;

      # TURN Server
      turn_uris = [ "turns:mistyttm.dev?transport=udp" "turns:mistyttm.dev?transport=tcp" ];
      turn_shared_secret_path = config.sops.secrets."turn_shared_secret".path;
      turn_user_lifetime = 86400000;
      turn_allow_guests = true;

      # URL Previews
      url_preview_enabled = true;
      max_spider_size = 10485760;

      # Rate Limiting
      rc_message = {
        per_second = 100;
        burst_count = 200;
      };
      rc_registration = {
        per_second = 10;
        burst_count = 20;
      };
      rc_registration_token_validity = {
        per_second = 10;
        burst_count = 20;
      };
      rc_joins = {
        local = {
          per_second = 10;
          burst_count = 20;
        };
        remote = {
          per_second = 10;
          burst_count = 20;
        };
      };
      rc_joins_per_room = {
        per_second = 10;
        burst_count = 20;
      };
      rc_invites = {
        per_room = {
          per_second = 10;
          burst_count = 20;
        };
        per_user = {
          per_second = 10;
          burst_count = 20;
        };
        per_issuer = {
          per_second = 10;
          burst_count = 20;
        };
        rc_third_party_invite = {
          per_second = 10;
          burst_count = 20;
        };
      };
    };
  };

  services.mautrix-discord = {
    enable = true;
    settings = {
      homeserver = {
        address = "http://localhost:${toString synapsePort}";
        domain = "mistyttm.dev";
      };
      appservice = {
        database = {
          uri = "postgres:///mautrix-discord?host=/run/postgresql&sslmode=disable";
        };
      };
      bridge = {
        direct-media = {
          server_name = "discord-media.mistyttm.dev";
        };
        permissions = {
          "mistyttm.dev" = "user";
        };
      };
    };
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

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "mautrix-discord" "matrix-synapse" ];
    ensureUsers = [
      {
        name = "mautrix-discord";
        ensureDBOwnership = true;
      }
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };
}
