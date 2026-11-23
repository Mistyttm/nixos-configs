{self, ...}: {
  flake.nixosModules.draupnir = {
    config,
    lib,
    pkgs,
    ...
  }: {
    lantian.harden.draupnir = {
      enable = true;
      enableConfinement = false;
      bindPaths = ["/var/lib/draupnir"];
    };
    systemd.services.draupnir.serviceConfig.WorkingDirectory = lib.mkForce "/";
    sops.secrets."mjolnir_access_token" = {
      sopsFile = self.secrets.synapse;
    };

    services.draupnir = {
      enable = true;
      package = pkgs.draupnir;
      settings = {
        homeserverUrl = "http://localhost:8008";
        rawHomeserverUrl = "https://mistyttm.dev";
        managementRoom = "#admin:mistyttm.dev";
      };

      secrets.accessToken = config.sops.secrets."mjolnir_access_token".path;
    };
  };
}
