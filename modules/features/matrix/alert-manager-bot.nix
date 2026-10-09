{self, ...}: {
  flake.nixosModules.matrix-alertmanager-bot = {config, ...}: {
    sops.secrets."matrix-alertmanager-token" = {
      sopsFile = self.secrets.matrix-alertmanager;
      key = "token";
    };
    sops.secrets."matrix-alertmanager-secret" = {
      sopsFile = self.secrets.matrix-alertmanager;
      key = "secret";
    };

    services.matrix-alertmanager = {
      enable = true;
      port = 9155;
      homeserverUrl = "https://mistyttm.dev";
      matrixUser = "@alerts:mistyttm.dev";
      mention = true;

      tokenFile = config.sops.secrets."matrix-alertmanager-token".path;
      secretFile = config.sops.secrets."matrix-alertmanager-secret".path;

      # Alertmanager receiver names map to rooms here. One room for now;
      # split into two (paging vs informational) later if volume grows.
      matrixRooms = [
        {
          receivers = ["infra-alerts"];
          roomId = "!dHiYTmwlzqjHMrmnHq:mistyttm.dev";
        }
      ];
    };
  };
}
