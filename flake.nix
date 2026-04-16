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
    # simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://opinionatedcache.cachix.org"
      "https://cache.flox.dev"
      "https://cache.nixos-cuda.org"
      "https://install.determinate.systems"
      "https://attic.xuyh0120.win/lantian"
      "https://misty-nixpkgs-extra.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "opinionatedcache.cachix.org-1:zDO4tZBL25vfhVFSHTT+0RNCjn5Z5nEs7sPiDZ6XhuE="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "misty-nixpkgs-extra.cachix.org-1:IaGsrS6TyLFv+wkdYjjWaY9lB2vywnmM7qUZw01kPj0="
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
      # simple-nixos-mailserver,
      self,
      chaotic,
      # nixos-hardware,
      pre-commit-hooks,
      determinate,
      nix-topology,
      nix-cachyos-kernel,
      firefox-addons,
      ...
    }:
    let
      system = "x86_64-linux";
      picosvgOverlay = _final: prev: {
        python313Packages = prev.python313Packages // {
          picosvg = prev.python313Packages.picosvg.overrideAttrs (_: {
            doCheck = false;
          });
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = commonOverlays ++ [ picosvgOverlay ];
      };
      homeVersion = "26.05"; # Update this when you update your NixOS version
      # overlay-satisfactory = final: prev: {
      #   satis = import satisfactory {
      #     system = final.stdenv.hostPlatform.system;
      #     config.allowUnfree = true;
      #   };
      # };
      localPackages =
        final:
        let
          discovered = nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
            directory = ./packages;
            callPackage = final.callPackage;
          };
        in
        builtins.mapAttrs (
          _name: value: if builtins.isAttrs value && value ? default then value.default else value
        ) discovered;
      overlay-packages = final: _prev: localPackages final;
      commonOverlays = [
        nix-topology.overlays.default
        overlay-packages
      ];
      commonModules = [
        ./modules/default.nix
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        determinate.nixosModules.default
        nix-topology.nixosModules.default
      ];
      overlay-wallpaper-engine = import ./patches/wallpaper-engine-plugin;
      overlay-libreoffice = import ./patches/libreoffice;
      overlay-tdarr = import ./patches/tdarr;
    in
    {
      hydraJobs = {
        nixos = builtins.mapAttrs (_: cfg: cfg.config.system.build.toplevel) self.nixosConfigurations;
      };
      overlays.default = overlay-packages;
      nixosConfigurations = {
        puppypc = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit homeVersion;
          };

          modules = commonModules ++ [
            ./hosts/puppypc/configuration.nix

            chaotic.nixosModules.default
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
                overlays = commonOverlays ++ [
                  nixpkgs-extra.overlays.default
                  nix-vscode-extensions.overlays.default
                  overlay-wallpaper-engine
                  overlay-libreoffice
                  nix-cachyos-kernel.overlays.pinned
                  firefox-addons.overlays.default
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
          modules = commonModules ++ [
            ./hosts/mistylappytappy/configuration.nix

            chaotic.nixosModules.default
            auto-cpufreq.nixosModules.default
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit spicetify-nix homeVersion; };
                users = {
                  misty = import ./hosts/mistylappytappy/home.nix;
                };
                sharedModules = [
                  inputs.sops-nix.homeManagerModules.sops
                ];
              };
              nixpkgs = {
                overlays = commonOverlays ++ [
                  nix-vscode-extensions.overlays.default
                  overlay-libreoffice
                  firefox-addons.overlays.default
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
          modules = commonModules ++ [
            ./hosts/thedogpark/configuration.nix

            # simple-nixos-mailserver.nixosModule
            {
              imports = [ nix-minecraft.nixosModules.minecraft-servers ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit homeVersion; };

              home-manager.users.misty = import ./hosts/thedogpark/home.nix;
              home-manager.users.steam = import ./hosts/thedogpark/steam.nix;

              nixpkgs = {
                overlays = commonOverlays ++ [ nix-minecraft.overlay ];
              };
            }
          ];
        };
        thekennel = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit homeVersion;
          };
          modules = commonModules ++ [
            ./hosts/thekennel/configuration.nix

            nixpkgs-extra.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit homeVersion; };

              home-manager.users.misty = import ./hosts/thekennel/home.nix;

              nixpkgs.overlays = commonOverlays ++ [
                nixpkgs-extra.overlays.default
                overlay-tdarr
              ];
            }
          ];
        };
        #foodbowl = nixpkgs.lib.nixosSystem {
        #  system = "aarch64-linux";
        #  specialArgs = {
        #    inherit homeVersion;
        #  };
        #  modules = [
        #    ./hosts/foodbowl/configuration.nix

        #    home-manager.nixosModules.home-manager
        #    sops-nix.nixosModules.sops
        #    nixos-hardware.nixosModules.raspberry-pi-4
        #    determinate.nixosModules.default
        #    {
        #      home-manager.useGlobalPkgs = true;
        #      home-manager.useUserPackages = true;
        #      home-manager.backupFileExtension = "backup";
        #      home-manager.extraSpecialArgs = { inherit homeVersion; };

        #      home-manager.users.misty = import ./hosts/foodbowl/home.nix;
        #    }
        #  ];
        #};
      };
      packages.x86_64-linux = localPackages pkgs;

      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      checks.x86_64-linux.dispatcharr = pkgs.callPackage ./tests/dispatcharr.nix { };

      checks.x86_64-linux.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt = {
            enable = true;
            package = nixpkgs.legacyPackages.${system}.nixfmt;
          };
          deadnix.enable = true;
          commitizen.enable = true;
        };
      };

      devShells.x86_64-linux.default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
        buildInputs = self.checks.x86_64-linux.pre-commit-check.enabledPackages ++ [
          nixpkgs.legacyPackages.${system}.just
        ];
      };

      # nix-topology - generate infrastructure diagrams from NixOS configs
      # Build with: nix build .#topology.x86_64-linux.config.output
      topology.x86_64-linux = import nix-topology {
        inherit pkgs;
        modules = [
          # Global topology configuration (networks, connections, external devices)
          ./topology
          { nixosConfigurations = self.nixosConfigurations; }
        ];
      };
    };
}
