{ config, ... }: {
  sops.secrets."mjolnir_access_token" = {
    sopsFile = ../../../secrets/synapse.yaml;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };

  services.mjolnir = {
    enable = true;
    homeserverUrl = "https://mistyttm.dev";
    managementRoom = "#moderation:mistyttm.dev";
    accessTokenFile = config.sops.secrets."mjolnir_access_token".path;
    pantalaimon = {
      enable = true;
      username = "mjolnir";
    };
  };
}