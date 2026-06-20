{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ffmpeg,
  networkmanager,
  SDL2,
  SDL2_ttf,
  SDL2_image,
  openssl,
  pkg-config,
  glib,
  libnl,
  git,
  libwebp,
  libtiff,
  polkit,
  libxml2,
  fetchgit,
  libx11,
  autoAddDriverRunpath,
}: let
  drc-hostap-src = fetchgit {
    url = "https://github.com/rolandoislas/drc-hostap.git";
    rev = "418e5e206786de2482864a0ec3a59742a33b6623"; # find the commit from the CMakeLists.txt
    hash = "sha256-0LZLNhGF5OC0AkVRFyP+vtjPJ5VEeIJF9ZfBpoJZdH4=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "vanilla-wiiu";
    version = "continuous-2026-06-05";
    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "vanilla-wiiu";
      repo = "vanilla";
      rev = "91ab3a0ccd1741f89d49b696e1da61ee0775f919";
      hash = "sha256-dThwQNNtP5V7PctSH0i7zgks73F15YHLEEWGg5BWrJI=";
      fetchSubmodules = true;
    };

    patches = [./hostap-nix-source.patch];

    postPatch = ''
      substituteInPlace pipe/linux/CMakeLists.txt \
        --replace-fail '@DRC_HOSTAP_SRC@' '${drc-hostap-src}'

      substituteInPlace gui/ui/ui_sdl.c \
        --replace-fail '<SDL_image.h>' '<SDL2/SDL_image.h>' \
        --replace-fail '<SDL_ttf.h>' '<SDL2/SDL_ttf.h>'
    '';

    nativeBuildInputs = [
      cmake
      pkg-config
      git
    ];

    buildInputs = [
      ffmpeg
      networkmanager
      libnl
      glib
      SDL2
      SDL2_ttf
      SDL2_image
      openssl
      libwebp
      libtiff
      polkit
      libxml2
      libx11
      autoAddDriverRunpath
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
    ];

    passthru.updateScript = ./update.sh;

    meta = {
      description = "";
      homepage = "https://github.com/vanilla-wiiu/vanilla";
      changelog = "https://github.com/vanilla-wiiu/vanilla/releases/tag/${finalAttrs.src.rev}";
      license = lib.licenses.gpl2Only;
      maintainers = with lib.maintainers; [mistyttm];
      mainProgram = "vanilla-wiiu";
      platforms = lib.platforms.all;
    };
  })
