{
  description = "NixOS configuration for Misty Rose's pack";

  inputs = {
    # unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    old-alvr.url = "github:nixos/nixpkgs/aebe249544837ce42588aa4b2e7972222ba12e8f";
    wivrnupdate-nixpkgs.url = "github:PassiveLemon/nixpkgs/wivrn-update";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  };

  outputs = inputs@{ nixpkgs, old-alvr, wivrnupdate-nixpkgs, home-manager, sddm-sugar-candy-nix, sops-nix, spicetify-nix, nix-minecraft, nix-vscode-extensions, ... }: let
      system = "x86_64-linux";
      vsc-extensions = nix-vscode-extensions.extensions.${system};
      overlay-alvr = final: prev: {
        old-alvr = import old-alvr {
          inherit system;
          config.allowUnfree = true;
        };
      };
      overlay-wivrn = final: prev: {
        wivrnupdate-nixpkgs = import wivrnupdate-nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
    nixpkgs.config.cudaSupprt = true;
    nixosConfigurations = {
      # TODO please change the hostname to your own
      mistylappytappy = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/mistylappytappy/configuration.nix

          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit spicetify-nix vsc-extensions;};

            # TODO replace ryan with your own username
            home-manager.users.misty = import ./hosts/mistylappytappy/home.nix;

            nixpkgs = {
              overlays = [
                sddm-sugar-candy-nix.overlays.default
              ];
            };
          }
        ];
      };
      puppypc = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/puppypc/configuration.nix

          home-manager.nixosModules.home-manager
          sddm-sugar-candy-nix.nixosModules.default
          sops-nix.nixosModules.sops
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            # inheriting vsc-extensions here for use in home-manager
            home-manager.extraSpecialArgs = {inherit spicetify-nix vsc-extensions;};

            # TODO replace ryan with your own username
            home-manager.users.misty = import ./hosts/puppypc/home.nix;

            nixpkgs = {
              overlays = [
                sddm-sugar-candy-nix.overlays.default
                overlay-alvr
                overlay-wivrn
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
