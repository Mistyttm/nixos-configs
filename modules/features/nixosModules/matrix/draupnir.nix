{self, ...}: {
  flake.nixosModules.draupnir = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets."mjolnir_access_token" = {
      sopsFile = self.secrets.synapse;
    };

    services.draupnir = {
      enable = true;
      package = pkgs.draupnir.override {nodejs_24 = pkgs.nodejs_22;};
      settings = {
        homeserverUrl = "http://localhost:8008";
        rawHomeserverUrl = "https://mistyttm.dev";
        managementRoom = "#admin:mistyttm.dev";
      };

      secrets.accessToken = config.sops.secrets."mjolnir_access_token".path;
    };
  };
}
