{
  self,
  inputs,
  ...
}:
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

  flake.packages = {
    x86_64-linux.thepetshop-iso =
      self.nixosConfigurations."thepetshop-x86_64".config.system.build.images.iso-installer;
    aarch64-linux.thepetshop-iso =
      self.nixosConfigurations."thepetshop-aarch64".config.system.build.images.iso-installer;
  };
}
