{self, ...}: {
  flake.nixosModules.dispatcharr-service = {...}: {
    imports = [
      self.nixosModules.dispatcharr
    ];

    lantian.harden.dispatcharr = {
      enable = true;
      postgresql = true;
      redis = "dispatcharr";
    };

    services.dispatcharr = {
      enable = true;
      openFirewall = true;
      extraGroups = ["media"];
    };
  };
}
