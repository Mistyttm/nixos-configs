{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.nixoptions =
    {
      config,
      ...
    }:
    {
      #! List of default nixosModule imports for all systems
      imports = [
        inputs.nix-index-database.nixosModules.default
        inputs.lix-module.nixosModules.lixFromNixpkgs
      ];

      sops.secrets."github_token" = {
        sopsFile = self.secrets.github;
        key = "github_token";
      };

      sops.templates."nix-netrc" = {
        path = "/etc/nix/netrc";
        owner = "root";
        group = "root";
        mode = "0600";
        content = ''
          machine github.com
          login token
          password ${config.sops.placeholder.github_token}
        '';
      };

      sops.templates."nix-access-tokens" = {
        path = "/etc/nix/access-tokens.conf";
        owner = "root";
        mode = "0600";
        content = ''
          access-tokens = github.com=${config.sops.placeholder.github_token}
        '';
      };

      nix = {
        settings = {
          cores = 2;
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          substituters = [
            "https://nix-community.cachix.org"
            "https://opinionatedcache.cachix.org"
            "https://cache.flox.dev"
            "https://cache.nixos-cuda.org"
            "https://attic.xuyh0120.win/lantian"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "opinionatedcache.cachix.org-1:zDO4tZBL25vfhVFSHTT+0RNCjn5Z5nEs7sPiDZ6XhuE="
            "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          ];
          trusted-users = [
            "misty"
          ];
        };
        optimise = {
          automatic = true;
        };
        extraOptions = ''
          netrc-file = /etc/nix/netrc
          !include /etc/nix/access-tokens.conf
        '';
      };

      nixpkgs = {
        overlays = [
          inputs.nix-cachyos-kernel.overlays.pinned
          self.overlays.default
          inputs.nix-vscode-extensions.overlays.default
        ];
        config = {
          permittedInsecurePackages = [
            "freeimage-unstable-2021-11-01"
            "libsoup-2.74.3"
          ];
          allowUnfree = true;
        };
      };

      systemd.services.nix-daemon.serviceConfig = {
        MemoryHigh = "20G";
        MemoryMax = "28G";
      };

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
      };

      programs.nix-index-database.comma.enable = true;
    };
}
