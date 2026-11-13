{self, ...}: {
  flake.nixosModules.jellystat-service = {config, ...}: {
    sops.secrets."jellystat/jwt_secret".sopsFile = self.secrets.media;

    services.jellystat = {
      enable = true;
      openFirewall = true;

      group = "media";

      settings = {
        JS_PORT = 3005;
        TZ = "Australia/Brisbane";
      };

      secretFiles.JWT_SECRET = config.sops.secrets."jellystat/jwt_secret".path;
    };
  };
}
