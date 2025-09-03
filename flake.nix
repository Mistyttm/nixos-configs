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
    nixpkgs-extra.url = "github:Mistyttm/nixpkgs-extra";
    satisfactory.url = "github:TomaSajt/nixpkgs/satisfactorymodmanager";
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
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # microvm = {
    #   url = "github:astro/microvm.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-xr,
      nixpkgs-extra,
      home-manager,
      sddm-sugar-candy-nix,
      sops-nix,
      spicetify-nix,
      nix-minecraft,
      nix-vscode-extensions,
      auto-cpufreq,
      simple-nixos-mailserver,
      self,
      kwin-effects-forceblur,
      chaotic,
      # microvm,
      satisfactory,
      ...
    }:
    let
      system = "x86_64-linux";
      homeVersion = "25.11"; # Update this when you update your NixOS version
      overlay-satisfactory = final: prev: {
        satis = import satisfactory {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
      nixpkgs.config.cudaSupport = true;

      nixosConfigurations = {
        puppypc = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit homeVersion kwin-effects-forceblur;
          };

          modules = [
            ./modules/default.nix
            ./hosts/puppypc/configuration.nix

            chaotic.nixosModules.default
            home-manager.nixosModules.home-manager
            sddm-sugar-candy-nix.nixosModules.default
            sops-nix.nixosModules.sops
#             nixpkgs-xr.nixosModules.nixpkgs-xr
            nixpkgs-extra.nixosModules.default
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit spicetify-nix homeVersion; };
                users = {
                  misty = import ./hosts/puppypc/home.nix;
                };
                sharedModules = [
                  inputs.sops-nix.homeManagerModules.sops
                ];
              };

              nixpkgs = {
                overlays = [
                  nixpkgs-extra.overlays.default
                  sddm-sugar-candy-nix.overlays.default
                  nix-vscode-extensions.overlays.default
                  overlay-satisfactory
#                   millennium.overlays.default
                ];
              };
            }
          ];
        };
        mistylappytappy = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit homeVersion;
          };
          modules = [
            ./modules/default.nix
            ./hosts/mistylappytappy/configuration.nix

            chaotic.nixosModules.default
            home-manager.nixosModules.home-manager
            auto-cpufreq.nixosModules.default
            sops-nix.nixosModules.sops
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit spicetify-nix homeVersion; };
                users = {
                  misty = import ./hosts/mistylappytappy/home.nix;
                  wagtailpsychology = import ./hosts/mistylappytappy/work.nix;
                };
                sharedModules = [
                  inputs.sops-nix.homeManagerModules.sops
                ];
              };
              nixpkgs = {
                overlays = [
                  sddm-sugar-candy-nix.overlays.default
                  nix-vscode-extensions.overlays.default
#                   millennium.overlays.default
                  # myPkgsOverlay
                ];
              };
            }
          ];
        };
        thedogpark = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit homeVersion inputs;
          };
          modules = [
            ./modules/default.nix
            ./hosts/thedogpark/configuration.nix

            simple-nixos-mailserver.nixosModule
            # microvm.nixosModules.microvm
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            {
              imports = [ nix-minecraft.nixosModules.minecraft-servers ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit homeVersion; };

              home-manager.users.misty = import ./hosts/thedogpark/home.nix;
              home-manager.users.steam = import ./hosts/thedogpark/steam.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              nixpkgs = {
                overlays = [
                  nix-minecraft.overlay
                  # myPkgsOverlay
                ];
              };
            }
          ];
        };
        thekennel = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit homeVersion;
          };
          modules = [
            ./hosts/thekennel/configuration.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            # microvm.nixosModules.microvm
            sops-nix.nixosModules.sops
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit homeVersion; };

              home-manager.users.misty = import ./hosts/thekennel/home.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              nixpkgs = {
                overlays = [
                  # myPkgsOverlay
                ];
              };
            }
          ];
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
