{...}: {
  # https://old.reddit.com/r/NixOS/comments/1pdtc3v/kde_plasma_is_slow_compared_to_any_other_distro/
  # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
  flake.overlays.kde-plasma-workspace-xdg-fix = final: prev: {
    kdePackages = prev.kdePackages.overrideScope (
      _kdeFinal: kdePrev: {
        plasma-workspace = let
          # the package we want to override
          basePkg = kdePrev.plasma-workspace;
          # a helper package that merges all the XDG_DATA_DIRS into a single directory.
          # runCommandLocal: no compiler needed (stdenvNoCC) and this is a sub-second file merge, so building locally beats a substituter round-trip. No unpack/fixup/wrap phases to opt out of either.
          xdgdataPkg =
            final.runCommandLocal "${basePkg.name}-xdgdata" {
              buildInputs = [basePkg];
            } ''
              mkdir -p $out/share
              ( IFS=:
                for DIR in $XDG_DATA_DIRS; do
                  if [[ -d "$DIR" ]]; then
                    ${prev.lib.getExe prev.lndir} -silent "$DIR" $out # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3741634437
                  fi
                done
              )
            '';
          # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper script and instead inject the path of the above helper package
          derivedPkg = basePkg.overrideAttrs (old: {
            # function-form composes with old.preFixup instead of clobbering it, in case plasma-workspace's own default.nix ever sets one
            preFixup =
              (old.preFixup or "")
              + ''
                for index in "''${!qtWrapperArgs[@]}"; do
                  if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                    unset -v "qtWrapperArgs[$((index+0))]"
                    unset -v "qtWrapperArgs[$((index+1))]"
                    unset -v "qtWrapperArgs[$((index+2))]"
                    unset -v "qtWrapperArgs[$((index+3))]"
                  fi
                done
                qtWrapperArgs=("''${qtWrapperArgs[@]}")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
              '';
          });
        in
          derivedPkg;
      }
    );
  };
}
