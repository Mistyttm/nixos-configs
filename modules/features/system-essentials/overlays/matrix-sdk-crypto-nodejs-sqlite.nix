# Remove once NixOS/nixpkgs#584291 reaches nixos-unstable.
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
