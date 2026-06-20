{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  obs-studio,
  qt6,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "obs-wayland-hotkeys-plus";
  version = "1.0.0-2";

  src = fetchFromGitHub {
    owner = "codycwiseman";
    repo = "wayland-hotkeys-plus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8JMihkSC+Fb0gbLg4vR8+nV4JI5CiPV3GTLqOL9qm0E=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    obs-studio
    qt6.qtbase
    qt6.qtwayland
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Global Wayland hotkeys and scene switching for OBS";
    homepage = "https://github.com/codycwiseman/wayland-hotkeys-plus";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [];
  };
})
