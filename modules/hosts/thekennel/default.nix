{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.thekennel = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.thekennelConfiguration
    ];
  };
}
