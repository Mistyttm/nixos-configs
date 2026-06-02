{
  proton-ge-bin,
  fetchzip,
}:
(proton-ge-bin.override {
  steamDisplayName = "Proton-GE-RTSP";
}).overrideAttrs
(
  finalAttrs: previousAttrs: {
    pname = "proton-ge-rtsp";
    version = "GE-Proton10-33-rtsp23-4";

    src = fetchzip {
      url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
      hash = "sha256-lzPsYYcrp5NoT3B0WFj3o10Z7tXx7xva1wEP3edeuqM=";
    };

    preFixup = ''
      sed -i 's|"display_name" "${finalAttrs.version}"|"display_name" "Proton-GE-RTSP"|' "$steamcompattool/compatibilitytool.vdf"
    '';

    passthru =
      (previousAttrs.passthru or {})
      // {
        updateScript = ./update.sh;
      };
  }
)
