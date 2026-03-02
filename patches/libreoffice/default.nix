_final: prev: {
  # Fix a build failure in libreoffice-qt (libreoffice-still with kdeIntegration)
  # caused by a broken noto-sans glob workaround that no longer matches font
  # filenames after noto-fonts started renaming variable fonts (removing [...]
  # suffixes from file names).
  #
  # The notoSubset function in libreoffice/default.nix runs:
  #   cp "${noto-fonts}/share/fonts/noto/NotoSansArabic["*.[ot]tf "$out/..."
  # which relies on files being named NotoSansArabic[...].ttf, but the rename
  # step 'rename s/\[.*\]// ...' now strips that, so the glob matches nothing.
  #
  # Upstream fix: NixOS/nixpkgs#494721 (merged, not yet in the locked revision)
  # This replaces the broken notoSubset result with noto-fonts directly,
  # matching exactly what the upstream fix does.
  #
  # libreoffice-qt is the wrapper; FONTCONFIG_FILE lives on the unwrapped inner
  # derivation, so we override the `unwrapped` argument passed to the wrapper.
  libreoffice-qt = prev.libreoffice-qt.override {
    unwrapped = prev.libreoffice-qt.unwrapped.overrideAttrs (old: {
      env = old.env // {
        FONTCONFIG_FILE = prev.makeFontsConf {
          fontDirectories = with prev; [
            amiri
            caladea
            carlito
            culmus
            dejavu_fonts
            rubik
            liberation-sans-narrow
            liberation_ttf_v2
            libertine
            linux-libertine-g
            noto-fonts-lgc-plus
            noto-fonts
            noto-fonts-cjk-sans
          ];
        };
      };
    });
  };
}
