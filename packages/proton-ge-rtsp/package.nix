{
  proton-ge-bin,
  fetchzip,
}:
proton-ge-bin.overrideAttrs (
  finalAttrs: previousAttrs: {
    steamDisplayName = "RTSP-GE-Proton";
    pname = "proton-ge-rtsp";
    version = "proton-rtsp-11.0-20260609-3";

    src = fetchzip {
      url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
      hash = "sha256-Toj9kApuJmmZahBjNWJjE/YfiWEXGi2Oq8PYm3Ub+nI=";
    };

    passthru =
      (previousAttrs.passthru or {})
      // {
        updateScript = ./update.sh;
      };
  }
)
