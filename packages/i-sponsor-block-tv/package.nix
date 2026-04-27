{
  lib,
  python3,
  fetchFromGitHub,
  pkg-config,
}:

# Locally override python3.pkgs to provide required dependency versions
let
  fetchPypi = python3.pkgs.fetchPypi;
  rich_click_1_8_9 = python3.pkgs.buildPythonPackage {
    pname = "rich-click";
    version = "1.8.9";
    pyproject = true;
    src = fetchPypi {
      pname = "rich_click";
      version = "1.8.9";
      hash = "sha256-/ZjAq53cHPnAt0Y/aNryi00AM6dCFM6wL3YbP/KvMTY=";
    };
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
    ];
    dependencies = [
      rich_14_1_0
      python3.pkgs.click
      python3.pkgs.typing-extensions
    ];
  };
  aiohttp_3_12_15 = python3.pkgs.buildPythonPackage {
    pname = "aiohttp";
    version = "3.12.15";
    pyproject = true;
    src = fetchPypi {
      pname = "aiohttp";
      version = "3.12.15";
      hash = "sha256-T8YThenJjXL830fm3YGDP0ey93wRTCnNZKNhvlenY6I=";
    };
    nativeBuildInputs = [ pkg-config ];
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
      python3.pkgs.pkgconfig
    ];
    dependencies = [
      python3.pkgs.attrs
      python3.pkgs.yarl
      python3.pkgs.multidict
      python3.pkgs.async-timeout
      python3.pkgs.aiohappyeyeballs
      python3.pkgs.aiosignal
      python3.pkgs.frozenlist
    ];
  };
  pyytlounge_2_3_0 = python3.pkgs.buildPythonPackage {
    pname = "pyytlounge";
    version = "2.3.0";
    pyproject = true;
    src = fetchPypi {
      pname = "pyytlounge";
      version = "2.3.0";
      hash = "sha256-696v7ptQo0u/ipIIvT46LClpnqmBhNn3Yvz/tLqOtiQ=";
    };
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
      python3.pkgs.hatchling
    ];
    dependencies = [ aiohttp_3_12_15 ];
  };
  rich_14_1_0 = python3.pkgs.buildPythonPackage {
    pname = "rich";
    version = "14.1.0";
    pyproject = true;
    src = fetchPypi {
      pname = "rich";
      version = "14.1.0";
      hash = "sha256-5Jeki4RLAyDUUAfN6/6u7Y2ypPS89J8V5FXPxK8R6qg=";
    };
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
      python3.pkgs.poetry-core
    ];
    dependencies = [
      python3.pkgs.markdown-it-py
      python3.pkgs.pygments
    ];
  };
  textual_5_3_0 = python3.pkgs.buildPythonPackage {
    pname = "textual";
    version = "5.3.0";
    pyproject = true;
    src = fetchPypi {
      pname = "textual";
      version = "5.3.0";
      hash = "sha256-G2Eoszmt7y4pjMI6tHdxgEQyQOzlwjLymyKWDv1ljU0=";
    };
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
      python3.pkgs.poetry-core
    ];
    dependencies = [
      rich_14_1_0
      python3.pkgs.platformdirs
      python3.pkgs.typing-extensions
    ];
  };
  textual_slider_0_2_0 = python3.pkgs.buildPythonPackage {
    pname = "textual-slider";
    version = "0.2.0";
    pyproject = true;
    src = fetchPypi {
      pname = "textual_slider";
      version = "0.2.0";
      hash = "sha256-zfKMx2T/EWOi8DZVoxJTosS0lm3f89DeU8TfEFkyd8c=";
    };
    # src = fetchurl {
    #   url = "https://files.pythonhosted.org/packages/40/aa/2019bbb5218e4c3461248281cef0a1dbc827995ba940a6fb1f929e34725d/textual_slider-0.2.0.tar.gz";
    #   hash = "sha256-zfKMx2T/EWOi8DZVoxJTosS0lm3f89DeU8TfEFkyd8c=";
    # };
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
    ];
    dependencies = [ textual_5_3_0 ];
  };
  xmltodict_0_15_1 = python3.pkgs.buildPythonPackage {
    pname = "xmltodict";
    version = "0.15.1";
    pyproject = true;
    src = fetchPypi {
      pname = "xmltodict";
      version = "0.15.1";
      hash = "sha256-PY1JEn885pedQKNtvK2W+LqxBtIy0ktJ791L0hcWmDw=";
    };
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
    ];
    dependencies = [ ];
  };
  ssdp_1_3_1 = python3.pkgs.buildPythonPackage {
    pname = "ssdp";
    version = "1.3.1";
    pyproject = true;
    src = fetchPypi {
      pname = "ssdp";
      version = "1.3.1";
      hash = "sha256-H9Fpk/Xp+3UOl1vaCAuMh0qkx3WdP0pB0y5BYuu+cZg=";
    };
    build-system = [
      python3.pkgs.setuptools
      python3.pkgs.wheel
      python3.pkgs.flit-scm
    ];
    dependencies = [ ];
  };
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "i-sponsor-block-tv";
  version = "2.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dmunozv04";
    repo = "iSponsorBlockTV";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AGjLehhGYz8FyojSFmSYKLCkHAExtpQiukQnTNt1YoY=";
  };

  build-system = [
    python3.pkgs.hatch-requirements-txt
    python3.pkgs.hatchling
  ];

  dependencies = [
    aiohttp_3_12_15
    python3.pkgs.appdirs
    python3.pkgs.async-cache
    pyytlounge_2_3_0
    rich_14_1_0
    rich_click_1_8_9
    ssdp_1_3_1
    textual_5_3_0
    textual_slider_0_2_0
    xmltodict_0_15_1
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
