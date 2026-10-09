# Skip test-fs-cp-async-file-modes when building nodejs-slim_26.
#
# Based on:
#   https://github.com/GreepTheSheep/nixos-config/commit/9da31efa2517982ab9f1943c9d98af65fa95b53d
#
# Node.js 26 runs test-fs-cp-async-file-modes, which chmods the setuid and
# setgid bits. Those chmods return EPERM inside the Nix build sandbox, so the
# test can never pass and the whole nodejs build fails.
# Upstream skips it too: https://github.com/NixOS/nixpkgs/issues/564449
{...}: {
  flake.overlays.nodejs = _final: prev: let
    inherit (prev) lib;

    skippedTest = "test-fs-cp-async-file-modes";
    pkg = prev.nodejs-slim_26;

    # The override is redundant once nixpkgs' checkFlags mention the test.
    fixedUpstream = lib.any (lib.hasInfix skippedTest) (pkg.checkFlags or []);
  in {
    nodejs-slim_26 =
      lib.warnIf fixedUpstream
      ''
        nodejs-slim_26: nixpkgs already skips ${skippedTest}, the overlay can be removed.
      ''
      (
        if fixedUpstream
        then pkg
        else
          pkg.overrideAttrs (old: {
            checkFlags = map (
              flag:
                if lib.hasPrefix "CI_SKIP_TESTS=" flag
                then "${flag},${skippedTest}"
                else flag
            ) (old.checkFlags or []);
          })
      );
  };
}
