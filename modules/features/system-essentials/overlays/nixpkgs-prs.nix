# Packages from my open nixpkgs PRs, built against our nixpkgs.
#
# To add a PR: add an input + an entry below, then `nix run .#write-flake`.
# To pick up new pushes: `nix flake update nixpkgs-pr-<number>`.
# Once a PR lands in our nixpkgs the entry warns at eval time and falls back
# to the nixpkgs package; delete the entry and its input then.
{inputs, ...}: {
  flake-file.inputs = {
    nixpkgs-pr-572724 = {
      url = "github:NixOS/nixpkgs/pull/572724/head";
      flake = false;
    };
    nixpkgs-pr-561246 = {
      url = "github:NixOS/nixpkgs/pull/561246/head";
      flake = false;
    };
    nixpkgs-pr-576407 = {
      url = "github:NixOS/nixpkgs/pull/576407/head";
      flake = false;
    };
  };

  flake.overlays.nixpkgs-prs = final: prev: let
    inherit (prev) lib;

    fromPR = {
      pr,
      attr,
      path,
      merged,
    }:
      if merged
      then
        lib.warn
        "${attr}: NixOS/nixpkgs#${pr} is already in nixpkgs, remove it and the nixpkgs-pr-${pr} input from the nixpkgs-prs overlay."
        prev.${attr}
      else final.callPackage "${inputs."nixpkgs-pr-${pr}"}/${path}" {};
  in {
    # tdarr: 2.87.01 -> 3.00.00
    tdarr = fromPR {
      pr = "572724";
      attr = "tdarr";
      path = "pkgs/by-name/td/tdarr/package.nix";
      merged = lib.versionAtLeast (prev.tdarr.version or "0") "3.00.00";
    };

    # cleanuparr: init
    cleanuparr = fromPR {
      pr = "561246";
      attr = "cleanuparr";
      path = "pkgs/by-name/cl/cleanuparr/package.nix";
      merged = prev ? cleanuparr;
    };

    # handbrake: drop ffmpeg A15 pgssubdec patch (fails to apply on ffmpeg 8.1.3)
    handbrake = fromPR {
      pr = "576407";
      attr = "handbrake";
      path = "pkgs/by-name/ha/handbrake/package.nix";
      merged =
        !lib.any (p: lib.hasInfix "A15-lavc-pgssubdec" (toString p))
        prev.handbrake.passthru.ffmpeg-hb.patches;
    };
  };
}
