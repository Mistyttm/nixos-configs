{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    omniflake = {
      url = "github:fzakaria/omniflake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deadlock-mod-manager = {
      url = "github:deadlock-mod-manager/deadlock-mod-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-jellyfin-pr.url = "github:NixOS/nixpkgs/pull/561130/head";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://opinionatedcache.cachix.org"
      "https://cache.flox.dev"
      "https://cache.nixos-cuda.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "opinionatedcache.cachix.org-1:zDO4tZBL25vfhVFSHTT+0RNCjn5Z5nEs7sPiDZ6XhuE="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  outputs = inputs: let
    of = inputs.omniflake.flakes;
    modules = of.import-tree ./modules;
  in
    of.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        modules
        of.home-manager.flakeModules.home-manager
        of.git-hooks-nix.flakeModule
        of.mkdocs-flake.flakeModule
        of.devshell.flakeModule
        of.nix-topology.flakeModule
        of.pkgs-by-name-for-flake-parts.flakeModule
      ];
    };
}
