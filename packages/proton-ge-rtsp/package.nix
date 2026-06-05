{
  proton-ge-bin,
  fetchzip,
  steamDisplayName ? "RTSP-GE-Proton",
}:
(proton-ge-bin.override { inherit steamDisplayName; }).overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "proton-ge-rtsp";
    version = "GE-Proton10-33-rtsp23-4";

    src = fetchzip {
      url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
      hash = "sha256-sP+xNPbeI1jbs081QvFmj48A/yG6IC9ZPZRvGkFZnX0=";
    };

    passthru = (previousAttrs.passthru or { }) // {
      updateScript = ./update.sh;
    };
  }
)
