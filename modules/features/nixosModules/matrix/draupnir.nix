{self, ...}: {
  flake.nixosModules.draupnir = {config, ...}: {
    sops.secrets."mjolnir_access_token" = {
      sopsFile = self.secrets.synapse;
    };

    services.draupnir = {
      enable = true;

      settings = {
        homeserverUrl = "https://mistyttm.dev";
        managementRoom = "#admin:mistyttm.dev";
      };

      secrets.accessToken = config.sops.secrets."mjolnir_access_token".path;
    };
  };
}
