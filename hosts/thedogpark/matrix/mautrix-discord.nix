{ config, lib, ... }: let
  maybeListener = lib.lists.findFirst (l: l.tls == false) null config.services.matrix-synapse.settings.listeners;
  synapsePort = if maybeListener == null then 8008 else maybeListener.port;
in {
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
}