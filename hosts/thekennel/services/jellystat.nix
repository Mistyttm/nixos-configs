{ config, ... }:
{
  sops.secrets."jellystat/jwt_secret" = {
    sopsFile = ../../../secrets/media.yaml;
    owner = config.services.jellystat.user;
    group = config.services.jellystat.group;
    mode = "0400";
  };

  sops.secrets."jellystat/postgres_password" = {
    sopsFile = ../../../secrets/media.yaml;
    owner = config.services.jellystat.user;
    group = config.services.jellystat.group;
    mode = "0400";
  };

  services.jellystat = {
    enable = true;
    openFirewall = true;
    port = 3005;

    group = "media";

    # Keep this false by default to avoid implicit PostgreSQL server conflicts.
    database = {
      createLocally = false;
      host = "127.0.0.1";
      port = 5432;
      name = "jellystat";
      user = "jellystat";
      passwordFile = config.sops.secrets."jellystat/postgres_password".path;
    };

    jwtSecretFile = config.sops.secrets."jellystat/jwt_secret".path;
    timeZone = "Australia/Brisbane";
  };
}
