{ self, inputs, ... }:
{
  flake.nixosConfigurations.thedogpark = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.thedogparkConfiguration
    ];
  };
}
