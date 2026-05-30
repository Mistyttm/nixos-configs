{
  stdenv,
  fetchPypi,
  python313,
  python313Packages,
}:

let
  getPythonPackage = name: builtins.getAttr name python313Packages;

  uuid7 = python313Packages.buildPythonPackage (finalAttrs: {
    pname = "uuid7";
    version = "0.1.0";
    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-jFeqMu50VtPMaMlcRTC8VxZG3vrAGJXPxzVFRJiUpjw=";
    };
    format = "setuptools";
    nativeBuildInputs = with python313Packages; [
      setuptools
      wheel
    ];
  });

  browserUseSdk = python313Packages.buildPythonPackage (finalAttrs: {
    pname = "browser_use_sdk";
    version = "3.4.2";
    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-vgULyAOzHsTp8j39cdncXxFg197AuWIyeRXK90OhAgg=";
    };
    format = "pyproject";
    nativeBuildInputs = with python313Packages; [
      hatchling
      pythonRelaxDepsHook
    ];
    propagatedBuildInputs = with python313Packages; [
      httpx
      pydantic
    ];
    doCheck = false;
    doInstallCheck = false;
  });

  bubus = python313Packages.buildPythonPackage (finalAttrs: {
    pname = "bubus";
    version = "1.5.6";
    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-GlRW8KV26GYTp71m6BmJG2d3eDILbikQlOM5sNnfLg0=";
    };
    format = "pyproject";
    nativeBuildInputs = with python313Packages; [ hatchling ];
    propagatedBuildInputs =
      with python313Packages;
      [
        aiofiles
        anyio
        portalocker
        pydantic
        typing-extensions
        uuid7
      ]
      ++ [ uuid7 ];
  });

  cdpUse = python313Packages.buildPythonPackage (finalAttrs: {
    pname = "cdp_use";
    version = "1.4.5";
    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-DaOjLfRjNqA/9aIrxrxELNfS8tUKEY/UhW8p039tJqA=";
    };
    format = "pyproject";
    nativeBuildInputs = with python313Packages; [ hatchling ];
    propagatedBuildInputs = with python313Packages; [
      httpx
      typing-extensions
      websockets
    ];
  });

  browserUse = python313Packages.buildPythonPackage (finalAttrs: {
    pname = "browser_use";
    version = "0.12.9";
    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-0xpFqZZ/y/pTqdf8bbXgi/fhOluOYudEn593Txm1xsw=";
    };
    format = "pyproject";
    nativeBuildInputs = with python313Packages; [
      hatchling
      pythonRelaxDepsHook
    ];
    pythonRelaxDeps = true;
    propagatedBuildInputs =
      map getPythonPackage [
        "aiofiles"
        "aiohttp"
        "anyio"
        "anthropic"
        "click"
        "cloudpickle"
        "google-api-core"
        "google-api-python-client"
        "google-auth"
        "google-auth-oauthlib"
        "google-genai"
        "groq"
        "httpx"
        "inquirerpy"
        "markdownify"
        "mcp"
        "ollama"
        "openai"
        "pillow"
        "portalocker"
        "posthog"
        "psutil"
        "pydantic"
        "pypdf"
        "pyotp"
        "python-docx"
        "python-dotenv"
        "reportlab"
        "requests"
        "rich"
        "screeninfo"
        "typing-extensions"
      ]
      ++ [
        browserUseSdk
        bubus
        cdpUse
        uuid7
      ];
  });

  pythonEnv = python313.withPackages (
    ps:
    map (name: builtins.getAttr name ps) [
      "boto3"
      "fastapi"
      "filelock"
      "langchain-anthropic"
      "langchain-aws"
      "langchain-core"
      "langchain-openai"
      "playwright"
      "pymupdf"
      "pyinstaller"
      "pyyaml"
      "uvicorn"
    ]
    ++ [ browserUse ]
  );

in
{ src }:
stdenv.mkDerivation {
  pname = "langhire-backend";
  version = "1.0.0";
  inherit src;

  nativeBuildInputs = [ pythonEnv ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    export PYTHONUNBUFFERED=1

    ${pythonEnv}/bin/python -m PyInstaller \
      --onefile \
      --name "langhire-backend-${stdenv.hostPlatform.config}" \
      --distpath dist-bin \
      --workpath build/pyinstaller \
      --specpath build \
      --paths "$PWD/backend" \
      --add-data "$PWD/backend/core:core" \
      --add-data "$PWD/backend/memory:memory" \
      --add-data "$PWD/backend/sources:sources" \
      --add-data "$PWD/backend/sources/plugins:sources/plugins" \
      --add-data "$PWD/cli:cli" \
      --hidden-import uvicorn.logging \
      --hidden-import uvicorn.lifespan.on \
      --hidden-import uvicorn.protocols.http.auto \
      --hidden-import uvicorn.protocols.http.h11_impl \
      --hidden-import uvicorn.protocols.websockets.auto \
      --hidden-import fastapi \
      --hidden-import langchain_openai \
      --hidden-import langchain_anthropic \
      --hidden-import langchain_aws \
      --hidden-import browser_use \
      --hidden-import browser_use.agent \
      --hidden-import browser_use.browser \
      --hidden-import browser_use.llm \
      --hidden-import playwright \
      --hidden-import playwright.async_api \
      --hidden-import filelock \
      --hidden-import pydantic_settings \
      --hidden-import psutil \
      --hidden-import yaml \
      --collect-all browser_use \
      --collect-all playwright \
      backend/main.py

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp dist-bin/langhire-backend-${stdenv.hostPlatform.config} $out/bin/langhire-backend
    chmod +x $out/bin/langhire-backend
    runHook postInstall
  '';

  meta.mainProgram = "langhire-backend";
}
