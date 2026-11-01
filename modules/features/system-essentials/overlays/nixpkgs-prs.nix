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
    nixpkgs-pr-538226 = {
      url = "github:NixOS/nixpkgs/pull/538226/head";
      flake = false;
    };
    nixpkgs-pr-580322 = {
      url = "github:NixOS/nixpkgs/pull/580322/head";
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

    # The PR adds this test. Package versions can't tell us: -gtk is already at
    # the PR's version, and the others can be bumped without the PR landing.
    gsrMerged = builtins.pathExists (prev.path + "/nixos/tests/gpu-screen-recorder.nix");
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

    # millennium: init at 3.6.1
    millennium = fromPR {
      pr = "538226";
      attr = "millennium";
      path = "pkgs/by-name/mi/millennium/package.nix";
      merged = prev ? millennium;
    };
    steamWithMillennium = fromPR {
      pr = "538226";
      attr = "steamWithMillennium";
      path = "pkgs/by-name/st/steamWithMillennium/package.nix";
      merged = prev ? steamWithMillennium;
    };

    # gpu-screen-recorder{,-gtk,-notification,-ui}: bump, modernize
    # The module side lives in modules/features/gpu-screenrecorder.nix.
    # ffmpeg_7: newer ffmpeg requires an NVENC API that the nvidia 595 driver
    # lacks, so gsr silently falls back to CPU encoding. Keep this pin after
    # the PR lands, until the driver catches up.
    gpu-screen-recorder =
      (fromPR {
        pr = "580322";
        attr = "gpu-screen-recorder";
        path = "pkgs/by-name/gp/gpu-screen-recorder/package.nix";
        merged = gsrMerged;
      }).override
      {
        ffmpeg = final.ffmpeg_7;
      };
    gpu-screen-recorder-gtk = fromPR {
      pr = "580322";
      attr = "gpu-screen-recorder-gtk";
      path = "pkgs/by-name/gp/gpu-screen-recorder-gtk/package.nix";
      merged = gsrMerged;
    };
    gpu-screen-recorder-notification = fromPR {
      pr = "580322";
      attr = "gpu-screen-recorder-notification";
      path = "pkgs/by-name/gp/gpu-screen-recorder-notification/package.nix";
      merged = gsrMerged;
    };
    gpu-screen-recorder-ui = fromPR {
      pr = "580322";
      attr = "gpu-screen-recorder-ui";
      path = "pkgs/by-name/gp/gpu-screen-recorder-ui/package.nix";
      merged = gsrMerged;
    };
  };
}
