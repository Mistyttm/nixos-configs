{self, ...}: {
  flake.nixosModules.jellystat-service = {config, ...}: {
    imports = [
      self.nixosModules.jellystat
    ];

    sops.secrets."jellystat/jwt_secret" = {
      sopsFile = self.secrets.media;
      owner = config.services.jellystat.user;
      group = config.services.jellystat.group;
      mode = "0400";
    };

    sops.secrets."jellystat/postgres_password" = {
      sopsFile = self.secrets.media;
      owner = config.services.jellystat.user;
      group = config.services.jellystat.group;
      mode = "0400";
    };

    services.jellystat = {
      enable = true;
      openFirewall = true;

      group = "media";

      settings = {
        port = 3005;
        timeZone = "Australia/Brisbane";
        jwtSecretFile = config.sops.secrets."jellystat/jwt_secret".path;

        # Use a local PostgreSQL instance for Jellystat.
        database = {
          enable = true;
          host = "127.0.0.1";
          port = 5432;
          name = "jellystat";
          user = "jellystat";
          passwordFile = config.sops.secrets."jellystat/postgres_password".path;
        };
      };
    };
  };
}
