# Host configuration for puppypc (desktop gaming PC)
# This is a flake-parts module
{ inputs, config, ... }:
let
  homeVersion = config.flake.shared.homeVersion;
  overlay-wallpaper-engine = config.flake.shared.overlays.overlay-wallpaper-engine;
in
{
  flake.nixosConfigurations.puppypc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      inherit homeVersion;
      inherit (inputs) kwin-effects-forceblur;
    };

    modules = [
      ../../modules/default.nix
      ../../hosts/puppypc/configuration.nix

      inputs.chaotic.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      inputs.nixpkgs-extra.nixosModules.default
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {
            inherit homeVersion;
            inherit (inputs) spicetify-nix;
          };
          users = {
            misty = import ../../hosts/puppypc/home.nix;
          };
          sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        };

        nixpkgs = {
          overlays = [
            inputs.nixpkgs-extra.overlays.default
            inputs.nix-vscode-extensions.overlays.default
            overlay-wallpaper-engine
          ];
        };
      }
    ];
  };
}
