{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.foodbowl = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      self.nixosModules.foodbowlConfiguration
    ];
  };

  # Flashable SD card image: `nix build .#foodbowl-sd-image`
  flake.packages.aarch64-linux.foodbowl-sd-image =
    self.nixosConfigurations.foodbowl.config.system.build.images.sd-card;
}
