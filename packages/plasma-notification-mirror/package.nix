{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6,
  systemd,
  kdePackages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-notification-mirror";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "MysteriousAeon";
    repo = "plasma-notification-mirror";
    rev = "v${finalAttrs.version}";
    hash = "sha256-K4ONjir2a+PYTcw13qEuKKey1UMlMiSgawskptJs30w=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    systemd
    kdePackages.layer-shell-qt
  ];

  dontWrapQtApps = true;

  postInstall = ''
    rm -rf $out/share
  '';

  meta = with lib; {
    description = "A small Wayland utility for KDE Plasma that mirrors desktop notification popups to one or more additional monitors.";
    homepage = "https://github.com/MysteriousAeon/plasma-notification-mirror";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [mistyttm];
  };
})
