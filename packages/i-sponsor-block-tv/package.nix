{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "i-sponsor-block-tv";
  version = "2.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dmunozv04";
    repo = "iSponsorBlockTV";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g0/AMtEyBwhBsejaDcscbCh3ksFkSLGMwEUD05wxPFQ=";
  };

  # Strip exact version pins so nixpkgs packages can satisfy the requirements.
  # The upstream requirements.txt uses == specifiers throughout; we relax them
  # to bare package names so hatch-requirements-txt doesn't reject our versions.
  postPatch = ''
    sed -i 's/==[0-9][0-9.]*//' requirements.txt
  '';

  build-system = with python3.pkgs; [
    hatch-requirements-txt
    hatchling
  ];

  dependencies = with python3.pkgs; [
    aiohttp
    appdirs
    async-cache
    rich
    rich-click
    ssdp
    textual
    xmltodict
    pyytlounge
    textual-slider
    pychromecast
    zeroconf
  ];

  pythonImportsCheck = [
    "iSponsorBlockTV"
  ];

  postBuild = ''
    # Re-wrap the program as i-sponsor-block-tv
    if [ -e "$out/bin/iSponsorBlockTV" ]; then
      mv "$out/bin/iSponsorBlockTV" "$out/bin/i-sponsor-block-tv"
      ln -sf "$out/bin/i-sponsor-block-tv" "$out/bin/iSponsorBlockTV"
    fi
  '';

  meta = {
    description = "SponsorBlock client for all YouTube TV clients";
    homepage = "https://github.com/dmunozv04/iSponsorBlockTV";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mistyttm ];
    mainProgram = "i-sponsor-block-tv";
  };
})
