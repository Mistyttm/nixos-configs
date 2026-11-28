{
  inputs,
  lib,
  config,
  ...
}: {
  # Inputs are declared next to the modules that use them (`flake-file.inputs.*`)
  # and rendered to .tack/pins.toml by `nix run .#write-lock`, which also runs
  # `tack update`. There is no flake.lock.
  flake-file.inputs = {
    nixpkgs = {
      url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
      group = "core";
    };

    flake-file = {
      url = lib.mkDefault "github:Mistyttm/flake-file/tack-additions";
      group = "core";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      group = "core";
    };
    import-tree = {
      url = "github:denful/import-tree";
      group = "core";
    };
    nix-wrapper-modules = {
      url = "github:nix-community/nix-wrapper-modules";
      group = "core";
    };
    tack = {
      url = "github:manic-systems/tack";
      group = "core";
    };
  };

  flake-file.tack.package = pkgs: inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default;

  flake-file.tack.allFollow = {
    nixpkgs = "nixpkgs";
    flake-parts = "flake-parts";
    home-manager = "home-manager";
    nixpkgs-lib = "nixpkgs";
  };

  imports = [inputs.flake-file.flakeModules.tack];

  perSystem = {pkgs, ...}: {
    packages.write-tack = config.flake-file.apps.write-tack pkgs;
    packages.write-lock = config.flake-file.apps.write-lock pkgs;
  };
}
