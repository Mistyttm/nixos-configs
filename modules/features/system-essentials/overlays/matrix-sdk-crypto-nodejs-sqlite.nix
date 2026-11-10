# Link matrix-sdk-crypto-nodejs against system sqlite.
#
# matrix-sdk-crypto-nodejs 0.6.6 fails to link on current nixos-unstable with
# `ld: cannot find -lsqlite3`, which breaks draupnir (and so thedogpark).
# Fixed upstream by https://github.com/NixOS/nixpkgs/pull/584291, which adds
# pkg-config + sqlite; this is the same change until it reaches our channel.
{...}: {
  flake.overlays.matrix-sdk-crypto-nodejs = final: prev: let
    inherit (prev) lib;

    pkg = prev.matrix-sdk-crypto-nodejs;

    fixedUpstream = lib.any (p: (p.pname or "") == "sqlite") (pkg.buildInputs or []);
  in {
    matrix-sdk-crypto-nodejs =
      lib.warnIf fixedUpstream
      ''
        matrix-sdk-crypto-nodejs: nixpkgs already links sqlite (NixOS/nixpkgs#584291), the overlay can be removed.
      ''
      (
        if fixedUpstream
        then pkg
        else
          pkg.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.pkg-config];
            buildInputs = (old.buildInputs or []) ++ [final.sqlite];
          })
      );
  };
}
