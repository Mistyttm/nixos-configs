{self, ...}: {
  flake.nixosModules.cleanuparr-service = {...}: {
    imports = [
      self.nixosModules.cleanuparr
    ];

    lantian.harden.cleanuparr = {
      enable = "jit";
      enableConfinement = false;
      postgresql = true;
      bindPaths = ["/mnt/media"];
    };

    services.cleanuparr = {
      enable = true;
      openFirewall = true;
      group = "media";
      settings.database.provider = "postgres";
    };
  };
}
