{
  lib,
  mkKdeDerivation,
  fetchFromGitHub,
  cmake,
  gettext,
  pkg-config,
  libX11,
  wayland,
  wayland-protocols,
  kdePackages,
  nix-update-script,
}:
mkKdeDerivation {
  pname = "klassy";
  version = "6.4.breeze6.4.0";
  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = "klassy";
    rev = "6.4.breeze6.4.0";
    hash = "sha256-+bYS2Upr84BS0IdA0HlCK0FF05yIMVbRvB8jlN5EOUM=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    gettext
    pkg-config
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    # Qt6
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtsvg
    kdePackages.qttools

    # KF6 libraries
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kguiaddons
    kdePackages.ki18n
    kdePackages.kiconthemes
    kdePackages.kcmutils
    kdePackages.kpackage
    kdePackages.kservice
    kdePackages.kwindowsystem
    kdePackages.kconfigwidgets
    kdePackages.frameworkintegration
    kdePackages.kcolorscheme
    kdePackages.kirigami

    # Wayland support
    kdePackages.kwayland
    wayland
    wayland-protocols
    kdePackages.plasma-wayland-protocols

    # KDE Decoration
    kdePackages.kdecoration

    # System libraries
    libX11
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
    "-DBUILD_QT6=ON"
    "-DBUILD_QT5=OFF"
  ];

  # Disable extra outputs that klassy doesn't produce
  outputs = [
    "out"
    "dev"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "A highly customizable binary Window Decoration, Application Style and Global Theme plugin for recent versions of the KDE Plasma desktop";
    homepage = "https://github.com/paulmcauley/klassy";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "klassy";
  };

  passthru.updateScript = nix-update-script { };
}
