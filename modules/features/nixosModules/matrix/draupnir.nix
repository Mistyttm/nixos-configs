{self, ...}: {
  flake.nixosModules.draupnir = {config, ...}: {
    sops.secrets."mjolnir_access_token" = {
      sopsFile = self.secrets.synapse;
    };

    services.draupnir = {
      enable = true;

      settings = {
        homeserverUrl = "http://localhost:8008";
        rawHomeserverUrl = "https://mistyttm.dev";
        managementRoom = "#admin:mistyttm.dev";
      };

      secrets.accessToken = config.sops.secrets."mjolnir_access_token".path;
    };
  };
}
