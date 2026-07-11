{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPypi,
  buildNpmPackage,
  python313,
  python313Packages,
  rustPlatform,
  wrapGAppsHook3,
  pkg-config,
  glib,
  gtk3,
  webkitgtk_4_1,
  librsvg,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "langhire";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "jaimaann";
    repo = "LangHire";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+z+lkxVb+0YxaaXiHlAqI/XXs6Vde4DM8uaQkvyOKUM=";
  };

  frontend = import ./frontend.nix {
    inherit buildNpmPackage;
    src = finalAttrs.src;
  };

  backend =
    (import ./backend.nix {
      inherit
        stdenv
        fetchPypi
        python313
        python313Packages
        ;
    })
    {src = finalAttrs.src;};

  backendSidecarName = "langhire-backend-${stdenv.hostPlatform.config}";

  # Cargo.lock lives in src-tauri/; we hoist it in postPatch so the hook finds it
  cargoLock.lockFile = "${finalAttrs.src}/src-tauri/Cargo.lock";

  # Run all cargo commands from the Tauri subdirectory
  buildAndTestSubdir = "src-tauri";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
    librsvg
    openssl
  ];

  # cargoSetupPostPatchHook validates Cargo.lock at the source root before
  # buildAndTestSubdir takes effect, so we hoist it here.
  postPatch = ''
    cp src-tauri/Cargo.lock Cargo.lock
    substituteInPlace src-tauri/tauri.conf.json \
      --replace '"frontendDist": "../dist"' '"frontendDist": "dist"'
  '';

  # Stage the frontend dist and backend binary where tauri's build expects them
  preBuild = ''
    mkdir -p dist src-tauri/dist
    cp -r ${finalAttrs.frontend}/share/langhire/frontend/dist/. dist/
    cp -r ${finalAttrs.frontend}/share/langhire/frontend/dist/. src-tauri/dist/
    mkdir -p src-tauri/binaries
    cp ${finalAttrs.backend}/bin/langhire-backend \
      src-tauri/binaries/${finalAttrs.backendSidecarName}
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set TAURI_DIST_DIR "$out/share/langhire/dist"
    )
  '';

  installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/libexec $out/share/langhire/binaries $out/share/langhire/dist

        # Cargo.toml names the crate "app"; the binary lands under the host triple
        # because nixpkgs sets CARGO_BUILD_TARGET. $releaseDir is not populated
        # when buildAndTestSubdir is active, so we use the explicit path.
        cp target/${stdenv.hostPlatform.config}/release/app $out/libexec/langhire

        # Install the frontend build output for Tauri runtime asset resolution.
        cp -r ${finalAttrs.frontend}/share/langhire/frontend/dist/. $out/share/langhire/dist/

        # Put the backend sidecar where Tauri resolves it at runtime. Tauri's sidecar
        # resolver on Linux expects the target-triple suffix.
        cp ${finalAttrs.backend}/bin/langhire-backend $out/libexec/${finalAttrs.backendSidecarName}
        cp ${finalAttrs.backend}/bin/langhire-backend $out/share/langhire/binaries/${finalAttrs.backendSidecarName}

        # Keep an unsuffixed compatibility name in case upstream switches to explicit
        # process spawning instead of shell.sidecar().
        ln -s ${finalAttrs.backendSidecarName} $out/libexec/langhire-backend
        ln -s ${finalAttrs.backendSidecarName} $out/share/langhire/binaries/langhire-backend

        # Thin launcher so $out/bin is on PATH
        cat > $out/bin/langhire <<EOF
    #!/bin/sh
    exec $out/libexec/langhire "\$@"
    EOF
        chmod +x $out/bin/langhire

        runHook postInstall
  '';

  meta = {
    description = "LangHire — AI-powered hiring assistant";
    homepage = "https://github.com/jaimaann/LangHire";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "langhire";
  };
})
