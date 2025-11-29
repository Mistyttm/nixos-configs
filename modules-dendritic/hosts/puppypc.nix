# Host configuration for puppypc (desktop gaming PC)
# This is a flake-parts module
{ inputs, config, ... }:
{
  flake.nixosConfigurations.puppypc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      inherit (config.flake.shared) homeVersion;
      inherit (inputs) kwin-effects-forceblur;
    };

    modules = [
      ../../modules/default.nix
      ../../hosts/puppypc/configuration.nix

      # Dendritic aspects
      config.flake.modules.nixos.git

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
            inherit (config.flake.shared) homeVersion;
            inherit (inputs) spicetify-nix;
          };
          users = {
            misty = {
              imports = [
                ../../hosts/puppypc/home.nix
                # Dendritic aspects for home-manager
                config.flake.modules.homeManager.git
              ];
            };
          };
          sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        };

        nixpkgs = {
          overlays = [
            inputs.nixpkgs-extra.overlays.default
            inputs.nix-vscode-extensions.overlays.default
            config.flake.shared.overlays.overlay-wallpaper-engine
          ];
        };
      }
    ];
  };
}
