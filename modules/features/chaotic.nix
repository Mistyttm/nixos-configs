{inputs, ...}: {
  # Don't make this follow our nixpkgs, nyx-cache only has hits for nyx's own pin.
  flake-file.inputs.chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

  flake.nixosModules.chaotic = {lib, ...}: {
    imports = [
      inputs.chaotic.nixosModules.default
    ];

    # mkAfter so this lands after nyx's own overlay.
    nixpkgs.overlays = lib.mkAfter [
      (_final: prev: {
        # Nyx's kernels are built against nyx's own nixpkgs pin, which predates kmodigest module
        # signing, so they ship no modules.cer (and their external modules no .ko.cer files).
        # Our aggregateModules unconditionally merges those certs, so only do it when the kernel
        # actually provides one. The asserts fail eval if upstream's postBuild changes shape.
        aggregateModules = args:
          (prev.aggregateModules args).overrideAttrs (
            old: let
              start = "cp --no-preserve=mode,ownership --remove-destination";
              end = ''| xargs -d'\n' cat >> modules.cer'';
            in {
              postBuild = assert lib.hasInfix start old.postBuild && lib.hasInfix end old.postBuild;
                lib.replaceStrings
                [start end]
                [
                  "if test -e modules.cer; then\n${start}"
                  "${end}\nfi"
                ]
                old.postBuild;
            }
          );

        # Nyx's Clang/LTO kernels pass LLVM's LD/AR/NM to out-of-tree modules but leave
        # STRIP/OBJCOPY/OBJDUMP/READELF as GNU binutils, which can't read the resulting .ko files
        # ("invalid entry in group"), so nvidia-open fails at the BTF step and in modules_install.
        # Point them at the LLVM the kernel already uses.
        linuxPackages_cachyos-lto-znver4 = prev.linuxPackages_cachyos-lto-znver4.extend (
          _kfinal: kprev: let
            llvmBin = builtins.dirOf (
              lib.removePrefix "NM=" (lib.findFirst (lib.hasPrefix "NM=") null kprev.kernel.commonMakeFlags)
            );
            llvmTools = {
              STRIP = "llvm-strip";
              OBJCOPY = "llvm-objcopy";
              OBJDUMP = "llvm-objdump";
              READELF = "llvm-readelf";
            };
            fixLlvmTools = drv:
              drv.overrideAttrs (old: {
                makeFlags =
                  map (
                    flag: let
                      var = lib.findFirst (v: lib.hasPrefix "${v}=" flag) null (lib.attrNames llvmTools);
                    in
                      if var != null
                      then "${var}=${llvmBin}/${llvmTools.${var}}"
                      else flag
                  )
                  old.makeFlags;
              });
          in {
            nvidiaPackages = kprev.nvidiaPackages.extend (
              _: nvPrev:
                lib.mapAttrs (
                  _: drv:
                    if lib.isDerivation drv && (drv.open or null) != null
                    then
                      drv.overrideAttrs (old: {
                        passthru =
                          old.passthru
                          // {
                            open = fixLlvmTools drv.open;
                          };
                      })
                    else drv
                )
                nvPrev
            );
          }
        );
      })
    ];
  };
}
