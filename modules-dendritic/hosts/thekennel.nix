# Host configuration for thekennel (Steam Deck)
# This is a flake-parts module
{ inputs, config, ... }:
let
  homeVersion = config.flake.shared.homeVersion;
in
{
  flake.nixosConfigurations.thekennel = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      inherit homeVersion;
    };

    modules = [
      ../../hosts/thekennel/configuration.nix

      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      inputs.jovian.nixosModules.jovian
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit homeVersion; };

        home-manager.users.misty = import ../../hosts/thekennel/home.nix;
      }
    ];
  };
}
