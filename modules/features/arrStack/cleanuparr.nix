{self, ...}: {
  flake.nixosModules.cleanuparr-service = {...}: {
    imports = [
      self.nixosModules.cleanuparr
    ];

    services.cleanuparr = {
      enable = true;
      openFirewall = true;
      group = "media";
      settings.database.provider = "postgres";
    };
  };
}
