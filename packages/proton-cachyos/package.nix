{
  proton-ge-bin,
  fetchzip,
}:
(proton-ge-bin.override {
  steamDisplayName = "Proton-CachyOS";
}).overrideAttrs
(
  finalAttrs: previousAttrs: {
    pname = "proton-cachyos";
    version = "11.0-20260521";

    src = fetchzip {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64.tar.xz";
      hash = "sha256-lzPsYYcrp5NoT3B0WFj3o10Z7tXx7xva1wEP3edeuqM=";
    };

    preFixup = ''
      sed -i 's|"display_name" "proton-cachyos-${finalAttrs.version}-slr-x86_64"|"display_name" "Proton-CachyOS"|' "$steamcompattool/compatibilitytool.vdf"
    '';

    passthru =
      (previousAttrs.passthru or {})
      // {
        updateScript = ./update.sh;
      };
  }
)
