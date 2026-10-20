{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "amethyst-kde";
  version = "0-unstable-2022-05-25";

  src = fetchFromGitHub {
    owner = "ddh4r4m";
    repo = "Amethyst";
    rev = "a6af9b7727e0337b98a5705bc60b9a6b841761c7";
    hash = "sha256-8F5CF+yzViyDUJuKDdbAP1KCgZx7HOqtJGWbxztBokk=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/desktoptheme $out/share/color-schemes
    cp -r plasma/desktoptheme/Amethyst $out/share/plasma/desktoptheme/
    cp color-schemes/Amethyst.colors $out/share/color-schemes/

    runHook postInstall
  '';

  meta = {
    description = "Amethyst Plasma style and colour scheme";
    homepage = "https://github.com/ddh4r4m/Amethyst";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [mistyttm];
  };
})
