{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      # Optional, by default this flake follows nixpkgs-unstable.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = inputs@{ nixpkgs, home-manager, sddm-sugar-candy-nix, sops-nix, spicetify-nix, nix-minecraft, nix-vscode-extensions, ... }: let
      system = "x86_64-linux";
    in {
    nixosConfigurations = {
      # TODO please change the hostname to your own
      mistylappytappy = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/mistylappytappy/configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit spicetify-nix;};

            # TODO replace ryan with your own username
            home-manager.users.misty = import ./hosts/mistylappytappy/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            nixpkgs = {
              overlays = [
                sddm-sugar-candy-nix.overlays.default
#                 spicetify-nix.homeManagerModules.default
              ];
            };
          }
        ];
      };
      puppypc = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/puppypc/configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          sddm-sugar-candy-nix.nixosModules.default
          sops-nix.nixosModules.sops
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit spicetify-nix;};

            # TODO replace ryan with your own username
            home-manager.users.misty = import ./hosts/puppypc/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            nixpkgs = {
              overlays = [
                sddm-sugar-candy-nix.overlays.default
#                 spicetify-nix.homeManagerModules.default
              ];
            };
          }
        ];
      };
      thedogpark = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/thedogpark/configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            imports = [nix-minecraft.nixosModules.minecraft-servers];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            # TODO replace ryan with your own username
            home-manager.users.misty = import ./hosts/thedogpark/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            nixpkgs = {
              overlays = [
                nix-minecraft.overlay
              ];
            };
          }
        ];
      };
      swaytest = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/swaytest/configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            # TODO replace ryan with your own username
            home-manager.users.misty = import ./hosts/swaytest/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            nixpkgs = {
              overlays = [
              ];
            };
          }
        ];
      };
    };
  };
}
