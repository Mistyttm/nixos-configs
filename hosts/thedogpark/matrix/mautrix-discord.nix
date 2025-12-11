{ config, lib, ... }:
let
  synapsePort = 8008;
in
{
  services.mautrix-discord = {
    enable = true;
    settings = {
      homeserver = {
        address = "http://localhost:${toString synapsePort}";
        domain = "mistyttm.dev";
      };
      appservice = {
        port = 8009;
        hostname = "0.0.0.0";
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
