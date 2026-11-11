{self, ...}: {
  flake.nixosModules.dispatcharr-service = {...}: {
    imports = [
      self.nixosModules.dispatcharr
    ];

    services.dispatcharr = {
      enable = true;
      openFirewall = true;
      extraGroups = ["media"];
    };
  };
}
