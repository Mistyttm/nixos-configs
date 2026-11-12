# Packages and NixOS modules from my open nixpkgs PRs, on top of our nixpkgs.
#
# To add a PR: add an input + an entry below, then `nix run .#write-flake`.
# Packages go in the overlay, modules in nixosModules.nixpkgs-prs.
# To pick up new pushes: `nix flake update nixpkgs-pr-<number>`.
# Once a PR lands in our nixpkgs the entry warns at eval time and falls back
# to the nixpkgs version; delete the entry and its input then.
{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;

  warnMerged = name: pr:
    lib.warn "${name}: NixOS/nixpkgs#${pr} is already in nixpkgs, remove it and the nixpkgs-pr-${pr} input from the nixpkgs-prs overlay.";
  # The PR adds this test. Package versions can't tell us: -gtk is already at
  # the PR's version, and the others can be bumped without the PR landing.
  # path is relative to nixos/modules.
in {
  flake-file.inputs = {
    nixpkgs-pr-572724 = {
      url = "github:NixOS/nixpkgs/pull/572724/head";
      flake = false;
    };
    nixpkgs-pr-561246 = {
      url = "github:NixOS/nixpkgs/pull/561246/head";
      flake = false;
    };
  };

  flake.nixosModules.nixpkgs-prs = {...}: {
  };

  flake.overlays.nixpkgs-prs = final: prev: let
    fromPR = {
      pr,
      attr,
      path,
      merged,
    }:
      if merged
      then warnMerged attr pr prev.${attr}
      else final.callPackage "${inputs."nixpkgs-pr-${pr}"}/${path}" {};
  in {
    # tdarr: 2.87.01 -> 3.04.00
    tdarr = fromPR {
      pr = "572724";
      attr = "tdarr";
      path = "pkgs/by-name/td/tdarr/package.nix";
      merged = lib.versionAtLeast (prev.tdarr.version or "0") "3.04.00";
    };

    # cleanuparr: init
    cleanuparr = fromPR {
      pr = "561246";
      attr = "cleanuparr";
      path = "pkgs/by-name/cl/cleanuparr/package.nix";
      merged = prev ? cleanuparr;
    };
  };
}
