# Host configuration for foodbowl (Raspberry Pi 4, aarch64)
# This is a flake-parts module
{ inputs, config, ... }:
let
  homeVersion = config.flake.shared.homeVersion;
in
{
  flake.nixosConfigurations.foodbowl = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";

    specialArgs = {
      inherit homeVersion;
    };

    modules = [
      ../../hosts/foodbowl/configuration.nix

      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit homeVersion; };

        home-manager.users.misty = import ../../hosts/foodbowl/home.nix;
      }
    ];
  };
}
