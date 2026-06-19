{
  proton-ge-bin,
  fetchzip,
  steamDisplayName ? "CachyOS-Proton",
}:
(proton-ge-bin.override { inherit steamDisplayName; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "proton-cachyos";
    version = "11.0-20260602";

    src = fetchzip {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64.tar.xz";
      hash = "sha256-PRGifq6wCKNv5DJiaAZ/6/iWfA6CVu++YZAkX5Ww97U=";
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
