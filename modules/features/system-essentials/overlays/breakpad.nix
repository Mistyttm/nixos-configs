{...}: {
  flake.overlays.breakpad = final: prev: let
    inherit (final) lib;
    brokenVersion = "2024.02.16";
    patchNames = map (p: baseNameOf (toString p)) (prev.breakpad.patches or []);
    fixed =
      prev.breakpad.version
      != brokenVersion
      || lib.any (lib.hasSuffix "fix-vtable-link.patch") patchNames;
  in {
    breakpad =
      lib.warnIf fixed
      "breakpad: nixpkgs now looks fixed (version ${prev.breakpad.version}, patches: ${toString patchNames}). See NixOS/nixpkgs#569323 and remove the breakpad overlay."
      (
        prev.breakpad.overrideAttrs (old: {
          env =
            (old.env or {})
            // {
              NIX_LDFLAGS = toString [
                (old.env.NIX_LDFLAGS or "")
                "--unresolved-symbols=ignore-in-object-files"
              ];
            };
        })
      );
  };
}
