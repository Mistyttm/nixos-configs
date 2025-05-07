{ pkgs, lib, config, ... }: let 
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
    # extraConfigFiles = [
    #   config.sops.secrets."registration_shared_secret".path
    # ];
    # enableRegistrationScript = true;
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
      turn_uris = [ "turns:mistyttm.dev?transport=udp" "turns:mistyttm.dev?transport=tcp" ];
      turn_shared_secret_path = config.sops.secrets."turn_shared_secret".path;
      turn_user_lifetime = 86400000;
      turn_allow_guests = true;

      url_preview_enabled = true;
      max_spider_size = 10485760;
    };
  };

  services.mautrix-discord = {
    enable = false;
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

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "mautrix-discord" ];
    ensureUsers = [
      {
        name = "mautrix-discord";
        ensureDBOwnership = true;
      }
    ];
  };
}
