{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pnpm_11,
  nodejs_24,
  pnpmConfigHook,
  fetchPnpmDeps,
  electron_43,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "encore";
  version = "0.2.4";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ScoreSaber";
    repo = "encore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w3hrFf9KbRlhTNiLN3uEAv1eoFw78NLOhtgCdo/BVkE=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 5;
    hash = "sha256-VU/OJaDmFLQ3o7Mbryncx0T4eO2Uc8XYFVCXeiDMocw=";
    pnpm = pnpm_11;
  };

  buildInputs = [
    electron_43
  ];

  nativeBuildInputs = [
    nodejs_24
    pnpm_11
    pnpmConfigHook
    makeWrapper
    copyDesktopItems
  ];

  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild
    pnpm --filter ./apps/main run build
    pnpm --filter ./apps/main run build:watchdog
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appDir="$out/lib/encore"
    mkdir -p "$appDir" "$out/bin"
    cp -r apps/main/out "$appDir/out"
    cp apps/main/package.json "$appDir/package.json"

    mkdir -p "$out/share/pixmaps"
    install -Dm644 assets/encore-icon.png "$out/share/pixmaps/encore.png"

    makeWrapper ${electron_43}/bin/electron "$out/bin/encore" \
      --unset ELECTRON_RUN_AS_NODE \
      --add-flags "$appDir"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "encore";
      desktopName = "Encore";
      comment = "A desktop companion for managing Beat Saber installs, mods and content";
      exec = "encore %U";
      icon = "encore";
      terminal = false;
      categories = ["Utility"];
      startupWMClass = "encore";
      mimeTypes = [
        "x-scheme-handler/encore"
        "x-scheme-handler/beatsaver"
        "x-scheme-handler/web+bsmap"
        "x-scheme-handler/modelsaber"
        "x-scheme-handler/bsplaylist"
      ];
    })
  ];

  passthru.updateScript = nix-update-script {extraArgs = ["--flake"];};

  meta = {
    description = "A lightweight desktop companion for managing Beat Saber installs, mods and other user generated content";
    homepage = "https://github.com/ScoreSaber/encore";
    changelog = "https://github.com/ScoreSaber/encore/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [mistyttm];
    mainProgram = "encore";
  };
})
