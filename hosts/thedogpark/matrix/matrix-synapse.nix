{ config, ... }: {
  imports = [
    ./coturn.nix
    ./mautrix-discord.nix
    ./mjolnir.nix
  ];

  sops.secrets."registration_shared_secret" = {
    sopsFile = ../../../secrets/synapse.yaml;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };
  sops.secrets."turn_shared_secret" = {
    sopsFile = ../../../secrets/synapse.yaml;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };
  sops.secrets."smtp_pass" = {
    sopsFile = ../../../secrets/synapse.yaml;
    owner = "matrix-synapse";
    group = "matrix-synapse";
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
    extraConfigFiles = [
      config.sops.secrets."smtp_pass".path
    ];
    settings = {
      server_name = "mistyttm.dev";
      public_baseurl = "https://mistyttm.dev";
      email = {
        smtp_host = "mail.mistyttm.dev";
        smtp_port = 587;
        smtp_user = "noreply@mistyttm.dev";
        notif_from = "Misty TTM Matrix <noreply@mistyttm.dev>";
        app_name = "my_branded_matrix_server";
        enable_notifs = true;
        notif_for_new_users = false;
        require_transport_security = true;
        invite_client_location = "https://app.element.io";
        validation_token_lifetime = "15m";
        subjects = {
          message_from_person_in_room = "[%(app)s] You have a message on %(app)s from %(person)s in the %(room)s room...";
          message_from_person = "[%(app)s] You have a message on %(app)s from %(person)s...";
          messages_from_person = "[%(app)s] You have messages on %(app)s from %(person)s...";
          messages_in_room = "[%(app)s] You have messages on %(app)s in the %(room)s room...";
          messages_in_room_and_others = "[%(app)s] You have messages on %(app)s in the %(room)s room and others...";
          messages_from_person_and_others = "[%(app)s] You have messages on %(app)s from %(person)s and others...";
          invite_from_person_to_room = "[%(app)s] %(person)s has invited you to join the %(room)s room on %(app)s...";
          invite_from_person = "[%(app)s] %(person)s has invited you to chat on %(app)s...";
          password_reset = "[%(server_name)s] Password reset";
          email_validation = "[%(server_name)s] Validate your email";
        };
      };
      registration_shared_secret_path = config.sops.secrets."registration_shared_secret".path;

      # TURN Server
      turn_uris = [ "turns:mistyttm.dev?transport=udp" "turns:mistyttm.dev?transport=tcp" ];
      turn_shared_secret_path = config.sops.secrets."turn_shared_secret".path;
      turn_user_lifetime = 86400000;
      turn_allow_guests = true;

      # URL Previews
      url_preview_enabled = true;
      max_spider_size = "20M";

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

        # Presence Tracking
        presence = {
          enabled = true;
          incluide_offline_users_on_sync = true;
        };

        # Avatar MIME type
        allowed_avatar_mimetypes = ["image/png" "image/jpeg" "image/gif"];
        max_avatar_size = "10M";
      };
    };
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
