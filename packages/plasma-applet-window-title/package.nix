{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasma-applet-window-title";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "dhruv8sh";
    repo = "plasma6-window-title-applet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pFXVySorHq5EpgsBz01vZQ0sLAy2UrF4VADMjyz2YLs=";
  };

  # Unused import of a private QML module that Plasma 6.8 no longer ships;
  # leaving it in stops the applet from loading at all.
  postPatch = ''
    substituteInPlace contents/ui/main.qml \
      --replace-fail "import org.kde.plasma.private.appmenu 1.0 as AppMenuPrivate" ""
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
    cp -r contents metadata.json $out/share/plasma/plasmoids/org.kde.windowtitle/

    runHook postInstall
  '';

  meta = {
    description = "Plasma 6 applet that shows the active window's title and icon";
    homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [mistyttm];
  };
})
