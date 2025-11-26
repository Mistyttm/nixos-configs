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
    # SDDM theme
    nixpkgs-extra.url = "github:Mistyttm/nixpkgs-extra";
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
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://mistyttm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "opinionatedcache.cachix.org-1:zDO4tZBL25vfhVFSHTT+0RNCjn5Z5nEs7sPiDZ6XhuE="
    ];
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-extra,
      home-manager,
      sops-nix,
      spicetify-nix,
      nix-minecraft,
      nix-vscode-extensions,
      auto-cpufreq,
      simple-nixos-mailserver,
      self,
      kwin-effects-forceblur,
      chaotic,
      jovian,
      nixos-hardware,
      ...
    }:
    let
      system = "x86_64-linux";
      homeVersion = "25.11"; # Update this when you update your NixOS version
      # overlay-satisfactory = final: prev: {
      #   satis = import satisfactory {
      #     system = final.stdenv.hostPlatform.system;
      #     config.allowUnfree = true;
      #   };
      # };
      overlay-wallpaper-engine = import ./patches/wallpaper-engine-plugin;
    in
    {
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
            sops-nix.nixosModules.sops
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
                  nix-vscode-extensions.overlays.default
                  overlay-wallpaper-engine
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
                  nix-vscode-extensions.overlays.default
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

              nixpkgs = {
                overlays = [
                  nix-minecraft.overlay
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

            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            jovian.nixosModules.jovian
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit homeVersion; };

              home-manager.users.misty = import ./hosts/thekennel/home.nix;
            }
          ];
        };
        foodbowl = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit homeVersion;
          };
          modules = [
            ./hosts/foodbowl/configuration.nix

            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            nixos-hardware.nixosModules.raspberry-pi-4
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit homeVersion; };

              home-manager.users.misty = import ./hosts/foodbowl/home.nix;
            }
          ];
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
