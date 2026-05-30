{ self, ... }:
{
  flake.nixosModules.jellyfin = {
    imports = [
      self.nixosModules.jellyfin-service
      self.nixosModules.jellystat-service
    ];
  };
}
