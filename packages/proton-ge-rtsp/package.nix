{
  proton-ge-bin,
  fetchzip,
  steamDisplayName ? "RTSP-GE-Proton",
}:
(proton-ge-bin.override {inherit steamDisplayName;}).overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "proton-ge-rtsp";
    version = "proton-rtsp-11.0-20260609-1";

    src = fetchzip {
      url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
      hash = "sha256-/YrUjR/Ynb0clNpXSaSlfpnqJ76ZfTYP9LR/WHHCMgk=";
    };

    passthru =
      (previousAttrs.passthru or {})
      // {
        updateScript = ./update.sh;
      };
  }
)
