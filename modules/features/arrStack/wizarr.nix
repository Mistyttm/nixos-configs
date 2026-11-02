{self, ...}: {
  flake.nixosModules.wizarr-service = {...}: {
    imports = [
      self.nixosModules.wizarr
    ];

    services.wizarr = {
      enable = true;
      openFirewall = true;
    };
  };
}
