{ pkgs, lib, config, ... }: let 
	maybeListener = lib.lists.findFirst (l: l.tls == false) null config.services.matrix-synapse.settings.listeners;
  	synapsePort = if maybeListener == null then 8008 else maybeListener.port;
in {
	sops.secrets."postgresql_discord_password" = {
    		sopsFile = ../../secrets/discordpostgresql.yaml;
    		owner = config.users.users.mautrix-discord.name;
    		group = config.users.users.mautrix-discord.group;
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

	};
	services.mautrix-discord = {
		enable = true;
		settings = {
			homeserver = {
				address = "http://localhost:${synapsePort}";
				domain = "mistyttm.dev";
			};
			appservice = {
				database = {
					uri = "postgres://mautrix:${config.sops.secrets.postgresql_discord_password.contents}@localhost/mautrix-discord?sslmode=disable";
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
      				ensurePermissions."DATABASE \"mautrix-discord\"" = "ALL PRIVILEGES";
    			}
  		];
	};
}
