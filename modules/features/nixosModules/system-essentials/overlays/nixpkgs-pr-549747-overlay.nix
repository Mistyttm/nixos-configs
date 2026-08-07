{...}: {
  # Local backport of: https://github.com/NixOS/nixpkgs/pull/549747
  flake.overlays.nixpkgs-pr-549747 = _final: prev: let
    lib = prev.lib;
    # PR 549747 adds the WITHOUT_GAVL cmake flag in frei0r; use that as a merge detector.
    upstreamHasFix = builtins.any (
      flag: builtins.match ".*WITHOUT_GAVL.*" (toString flag) != null
    ) (prev.frei0r.cmakeFlags or []);
  in
    lib.warnIf upstreamHasFix ''
      nixpkgs-pr-549747 overlay is obsolete: nixpkgs already contains the frei0r/gavl fix from https://github.com/NixOS/nixpkgs/pull/549747.
      Remove self.overlays.nixpkgs-pr-549747 from your nixpkgs overlays list.
    ''
    (
      if upstreamHasFix
      then {}
      else {
        frei0r = prev.frei0r.overrideAttrs (old: let
          oldBuildInputs = old.buildInputs or [];
          oldNativeBuildInputs = old.nativeBuildInputs or [];
          hasCuda = builtins.any (pkg: (pkg.pname or null) == "cuda_cudart") oldBuildInputs;
          noGavlBuildInputs = lib.lists.remove prev.gavl oldBuildInputs;
        in {
          nativeBuildInputs = oldNativeBuildInputs ++ lib.optionals hasCuda [prev.cudaPackages.cuda_nvcc];
          buildInputs =
            noGavlBuildInputs
            ++ lib.optionals prev.stdenv.hostPlatform.isLinux [prev.gavl];
          cmakeFlags =
            (old.cmakeFlags or [])
            ++ [
              (lib.cmakeBool "WITHOUT_GAVL" (!prev.stdenv.hostPlatform.isLinux))
            ]
            ++ lib.optionals hasCuda [
              (lib.cmakeFeature "CUDAToolkit_ROOT" "${lib.getBin prev.cudaPackages.cuda_nvcc}")
            ];
        });

        gavl = prev.gavl.overrideAttrs (old: {
          meta = (old.meta or {}) // {platforms = lib.platforms.linux;};
        });
      }
    );
}
