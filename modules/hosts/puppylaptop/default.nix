{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.puppylaptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.puppylaptopConfiguration
    ];
  };
}
