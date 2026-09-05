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
  libx11,
  autoAddDriverRunpath,
  unstableGitUpdater,
}: let
  drc-hostap-src = fetchFromGitHub {
    owner = "vanilla-wiiu";
    repo = "drc-hostap";
    rev = "257096accc39f9c2750a7718ff5751108d15f668";
    hash = "sha256-W6oSFMym9vOK6Q7EQA0yyGuCqJmSNKD0Ff21lLSWkAg=";
  };
in
  stdenv.mkDerivation (_finalAttrs: {
    pname = "vanilla-wiiu";
    version = "0-unstable-2026-08-26";
    __structuredAttrs = true;
    strictDeps = true;

    outputs = ["out" "dev"];

    src = fetchFromGitHub {
      owner = "vanilla-wiiu";
      repo = "vanilla";
      rev = "ec0783f945e5b4933734c516953404fd7c48bad5";
      hash = "sha256-JBFvtTIwIQq8TQmIiOvxhR3+urLOet6F2W6FoisCOHw=";
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

    postInstall = ''
      # namespace to match pname.
      mv "$out/bin/vanilla" "$out/bin/vanilla-wiiu"
      mv "$out/bin/vanilla-pipe" "$out/bin/vanilla-wiiu-pipe"
      substituteInPlace "$out/share/applications/com.mattkc.vanilla.desktop" \
        --replace-fail "Exec=vanilla" "Exec=vanilla-wiiu"

      # include/vanilla.h + lib/libvanilla.a are dev artifacts for embedding
      # libvanilla, not needed by the GUI app itself at runtime.
      moveToOutput include "$dev"
      moveToOutput lib "$dev"
    '';

    passthru.updateScript = unstableGitUpdater {
      branch = "master";
      hardcodeZeroVersion = true;
    };

    meta = {
      description = "";
      homepage = "https://github.com/vanilla-wiiu/vanilla";
      changelog = "https://github.com/vanilla-wiiu/vanilla/releases/tag/continuous";
      license = lib.licenses.gpl2Only;
      maintainers = with lib.maintainers; [mistyttm];
      mainProgram = "vanilla-wiiu";
      platforms = lib.platforms.all;
    };
  })
