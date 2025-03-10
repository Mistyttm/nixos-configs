{
  description = "NixOS configuration for Misty Rose's pack";

  inputs = {
    # unstable
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    # SDDM theme (DOESNT WORK)
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    # Spotify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Minecraft server management
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    # VSCode extensions
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs@{ nixpkgs, nixpkgs-xr, home-manager, sddm-sugar-candy-nix, sops-nix, spicetify-nix, nix-minecraft, nix-vscode-extensions, auto-cpufreq, ... }: let
      system = "x86_64-linux";
      vsc-extensions = nix-vscode-extensions.extensions.${system};
    in {
    nixpkgs.config.cudaSupport = true;
    nixosConfigurations = {
      puppypc = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/default.nix
          ./hosts/puppypc/configuration.nix

          home-manager.nixosModules.home-manager
          sddm-sugar-candy-nix.nixosModules.default
          sops-nix.nixosModules.sops
          nixpkgs-xr.nixosModules.nixpkgs-xr
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit spicetify-nix vsc-extensions; };
              users = {
                misty = import ./hosts/puppypc/home.nix;
              };
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
            };

            nixpkgs = {
              overlays = [
                sddm-sugar-candy-nix.overlays.default
              ];
            };
          }
        ];
      };
      mistylappytappy = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/default.nix
          ./hosts/mistylappytappy/configuration.nix

          home-manager.nixosModules.home-manager
          auto-cpufreq.nixosModules.default
          sops-nix.nixosModules.sops
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit spicetify-nix vsc-extensions; };
              users = {
                misty = import ./hosts/mistylappytappy/home.nix;
              };
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
            };
            nixpkgs = {
              overlays = [
                sddm-sugar-candy-nix.overlays.default
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
    };
  };
}
