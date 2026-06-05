{
  proton-ge-bin,
  fetchzip,
  steamDisplayName ? "CachyOS-Proton",
}:
(proton-ge-bin.override { inherit steamDisplayName; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "proton-cachyos";
    version = "11.0-20260521";

    src = fetchzip {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64.tar.xz";
      hash = "sha256-OrZfLv0FV+fhDuhbmcbMhtylDTMwTfRAvENh/v7iIr8=";
    };

    preFixup = ''
      sed -i 's/"display_name"[[:space:]]*"[^"]*"/"display_name"\t\t"${steamDisplayName}"/' \
        "$steamcompattool/compatibilitytool.vdf"
    '';

    passthru = (previousAttrs.passthru or { }) // {
      updateScript = ./update.sh;
    };
  }
)
