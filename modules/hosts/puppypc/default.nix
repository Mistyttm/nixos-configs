{ self, inputs, ... }:
{
  flake.nixosConfigurations.puppypc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.puppypcConfiguration
    ];
  };
}
