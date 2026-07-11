{self, ...}: {
  flake.nixosModules.arrStack = {
    imports = [
      self.nixosModules.bazarr
      self.nixosModules.dispatcharr
      self.nixosModules.flaresolverr
      self.nixosModules.prowlarr
      self.nixosModules.radarr
      self.nixosModules.recyclarr
      self.nixosModules.seerr
      self.nixosModules.sonarr
      self.nixosModules.tdarr
    ];

    users.groups.media = {
      gid = 986;
    };
  };
}
