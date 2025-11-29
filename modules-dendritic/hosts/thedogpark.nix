# Host configuration for thedogpark (server with mailserver, matrix)
# This is a flake-parts module
{ inputs, config, ... }:
let
  homeVersion = config.flake.shared.homeVersion;
in
{
  flake.nixosConfigurations.thedogpark = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      inherit homeVersion inputs;
    };

    modules = [
      ../../modules/default.nix
      ../../hosts/thedogpark/configuration.nix

      inputs.simple-nixos-mailserver.nixosModule
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      {
        imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit homeVersion; };

        home-manager.users.misty = import ../../hosts/thedogpark/home.nix;
        home-manager.users.steam = import ../../hosts/thedogpark/steam.nix;

        nixpkgs = {
          overlays = [
            inputs.nix-minecraft.overlay
          ];
        };
      }
    ];
  };
}
