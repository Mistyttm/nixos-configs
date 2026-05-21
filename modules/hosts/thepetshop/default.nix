{ self, inputs, ... }:
{
  flake.nixosConfigurations."thepetshop-x86_64" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.thepetshopInstaller
    ];
  };

  flake.nixosConfigurations."thepetshop-aarch64" = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      self.nixosModules.thepetshopInstaller
    ];
  };
}
