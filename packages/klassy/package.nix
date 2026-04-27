{
  lib,
  fetchFromGitHub,
  gettext,
  pkg-config,
  kdePackages,
}:
kdePackages.mkKdeDerivation {
  pname = "klassy";
  version = "6.4.breeze6.4.0";
  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = "klassy";
    rev = "6.4.breeze6.4.0";
    hash = "sha256-+bYS2Upr84BS0IdA0HlCK0FF05yIMVbRvB8jlN5EOUM=";
  };

  extraNativeBuildInputs = [
    gettext
    pkg-config
  ];

  extraBuildInputs = [
    kdePackages.extra-cmake-modules
    # Required Qt6 components
    kdePackages.qtbase
    kdePackages.qtsvg

    # Required KF6 components
    kdePackages.kcoreaddons
    kdePackages.kcolorscheme
    kdePackages.kconfig
    kdePackages.kcmutils
    kdePackages.kguiaddons
    kdePackages.ki18n
    kdePackages.kiconthemes
    kdePackages.kwindowsystem

    # Required for window decoration build
    kdePackages.kdecoration
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
    "-DBUILD_QT6=ON"
    "-DBUILD_QT5=OFF"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "A highly customizable binary Window Decoration, Application Style and Global Theme plugin for recent versions of the KDE Plasma desktop";
    homepage = "https://github.com/paulmcauley/klassy";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "klassy";
  };
}
