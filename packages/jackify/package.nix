{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
  protontricks,
  p7zip,
  nix-update-script,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "jackify";
  version = "0.8.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Omni-guides";
    repo = "Jackify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e/uplu01VcK7RBbeAWvFVXL94K2EhLBfTo30mXI6IMk=";
  };

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace-fail \
      "vdf @ git+https://github.com/solsticegamestudios/vdf.git" \
      "vdf>=3.4"
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    packaging
    psutil
    pycryptodomex
    pyside6
    pyyaml
    requests
    tqdm
    vdf
    watchdog
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postFixup = ''
    for program in jackify jackify-gui; do
      wrapProgram "$out/bin/$program" \
        --prefix PATH : "${lib.makeBinPath [protontricks p7zip]}"
    done
  '';

  pythonImportsCheck = [
    "jackify"
  ];

  passthru.updateScript = nix-update-script {extraArgs = ["--flake"];};

  meta = {
    description = "Manage Wabbajack modlists on Linux and Steam Deck";
    homepage = "https://github.com/Omni-guides/Jackify";
    changelog = "https://github.com/Omni-guides/Jackify/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [mistyttm];
    platforms = lib.platforms.linux;
    mainProgram = "jackify";
  };
})
