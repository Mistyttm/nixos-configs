{
  proton-ge-bin,
  fetchzip,
}:
proton-ge-bin.overrideAttrs (
  finalAttrs: previousAttrs: {
    steamDisplayName = "CachyOS-Proton";
    pname = "proton-cachyos";
    version = "11.0-20260703";

    src = fetchzip {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64.tar.xz";
      hash = "sha256-jOcPeEkBBPPNqyjXBoHm1Nk8AexPiLhx5+385NjUPT0=";
    };

    preFixup = ''
      sed -i 's/"display_name"[[:space:]]*"[^"]*"/"display_name"\t\t"${finalAttrs.steamDisplayName}"/' \
        "$steamcompattool/compatibilitytool.vdf"
    '';

    passthru = (previousAttrs.passthru or { }) // {
      updateScript = ./update.sh;
    };
  }
)
