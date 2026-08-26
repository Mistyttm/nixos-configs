{self, ...}: {
  flake.nixosModules.matrix = {...}: {
    imports = [
      self.nixosModules.matrix-synapse
      self.nixosModules.mautrix-discord
      self.nixosModules.coturn
      self.nixosModules.matrix-state-compressor
      self.nixosModules.ketesa
      self.nixosModules.draupnir
      self.nixosModules.matrix-notify
    ];
    sops.secrets."shared_secret_auth_config" = {
      sopsFile = self.secrets.synapse;
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };

    services.matrix-notify = {
      enable = true;
      roomId = "alerts:mistyttm.dev"; # same room, or a separate one for noisier stuff
      watchedUnits = [
        "matrix-synapse.service"
        "postgresql.service"
        "nginx.service"
        "coturn.service"
        "mautrix-discord.service"
        "draupnir.service"
        "mistyttmpersonalsite.service"
        "acme-mistyttm.dev.service"
        "acme-jellyfin.mistyttm.dev.service"
        "synapse-compress-state.service" # thekennel too, if you want the weekly VACUUM watched
      ];
    };
  };
}
