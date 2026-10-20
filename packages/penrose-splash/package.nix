{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "penrose-splash";
  version = "2.0.2-unstable-2026-09-04";

  # The repo also carries large video sources for every splash; only fetch Penrose.
  src = fetchFromGitHub {
    owner = "dgudim";
    repo = "themes";
    rev = "cf8557d1444ab35100e9f4c5ad8f063966520d9b";
    sparseCheckout = ["KDE-loginscreens/Penrose"];
    hash = "sha256-gv6Iz9I4MvZnXAO1SbT4ONiek1leI7b93o1XBjUvCCI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/look-and-feel
    cp -r KDE-loginscreens/Penrose $out/share/plasma/look-and-feel/Penrose
    rm -f $out/share/plasma/look-and-feel/Penrose/.nomedia

    runHook postInstall
  '';

  meta = {
    description = "Penrose triangle Plasma 6 splash screen";
    homepage = "https://store.kde.org/p/2124805";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [mistyttm];
  };
})
