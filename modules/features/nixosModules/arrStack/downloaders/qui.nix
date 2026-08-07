{self, ...}: {
  flake.nixosModules.qui = {config, ...}: {
    sops.secrets."qui_session_key" = {
      sopsFile = self.secrets.media;
      owner = "root";
      group = "root";
    };

    services.qui = {
      enable = true;
      group = "media";
      openFirewall = true;
      secretFile = config.sops.secrets."qui_session_key".path;
      settings = {
        port = 7476;
        metricsEnabled = true;
      };
    };
  };
}
