{self, ...}: {
  flake.nixosModules.mautrix-discord = {config, ...}: let
    synapsePort = config.services.matrix-synapse.settings.listnerss.port;
  in {
    sops.secrets."shared_secret_auth_config" = {
      sopsFile = self.secrets.synapse;
      owner = "mautrix-discord";
      group = "mautrix-discord";
    };

    sops.templates."mautrix-discord-env" = {
      content = ''
        MAUTRIX_DISCORD_BRIDGE_LOGIN_SHARED_SECRET=${config.sops.placeholder."shared_secret_auth_config"}
      '';
    };

    services.mautrix-discord = {
      enable = true;
      registerToSynapse = true;
      environmentFile = config.sops.templates."mautrix-discord-env".path;
      settings = {
        homeserver = {
          address = "http://localhost:${toString synapsePort}";
          domain = "mistyttm.dev";
        };
        appservice = {
          address = "http://localhost:8009";
          port = 8009;
          hostname = "0.0.0.0";
          database = {
            type = "postgres";
            uri = "postgres:///mautrix-discord?host=/run/postgresql&sslmode=disable";
          };
        };
        bridge = {
          sync_direct_chat_list = true;
          startup_private_channel_create_limit = 20;
          restricted_rooms = true;
          mute_channels_on_create = true;
          federate_rooms = false;
          delete_portal_on_channel_delete = true;
          login_shared_secret_map = {
            "mistyttm.dev" = "$MAUTRIX_DISCORD_BRIDGE_LOGIN_SHARED_SECRET"; # from environmentFile, see below
          };
          direct_media = {
            enabled = true;
            server_name = "discord-media.mistyttm.dev";
          };
          permissions = {
            "mistyttm.dev" = "user";
            "@misty_ttm:mistyttm.dev" = "admin";
          };
          backfill = {
            forward_limits = {
              initial = {
                dm = 50;
                channel = 30;
                thread = 20;
              };
              missed = {
                dm = -1;
                channel = 50;
                thread = 20;
              };
            };
            max_guild_members = 100;
          };
          encryption = {
            allow = true;
            default = true;
            allow_key_sharing = true;
          };
        };
        logging = {
          min_level = "info";
        };
      };
    };
  };
}
