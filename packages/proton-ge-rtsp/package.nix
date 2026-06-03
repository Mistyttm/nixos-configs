{
  proton-ge-bin,
  fetchzip,
  steamDisplayName ? "RTSP-GE-Proton",
}:
(proton-ge-bin.override { inherit steamDisplayName; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "proton-ge-rtsp";
    version = "GE-Proton10-33-rtsp24-1";

    src = fetchzip {
      url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
      hash = "sha256-KVc5YXJea0eQImKUPg6eW7uSSe1e+mncB4cSBV4IKME=";
    };

    passthru = (previousAttrs.passthru or { }) // {
      updateScript = ./update.sh;
    };
  }
)
