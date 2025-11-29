# Host configuration for mistylappytappy (laptop with work user)
# This is a flake-parts module
{ inputs, config, ... }:
let
  homeVersion = config.flake.shared.homeVersion;
in
{
  flake.nixosConfigurations.mistylappytappy = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      inherit homeVersion;
    };

    modules = [
      ../../modules/default.nix
      ../../hosts/mistylappytappy/configuration.nix

      inputs.chaotic.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.auto-cpufreq.nixosModules.default
      inputs.sops-nix.nixosModules.sops
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
            misty = import ../../hosts/mistylappytappy/home.nix;
            wagtailpsychology = import ../../hosts/mistylappytappy/work.nix;
          };
          sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        };
        nixpkgs = {
          overlays = [
            inputs.nix-vscode-extensions.overlays.default
          ];
        };
      }
    ];
  };
}
