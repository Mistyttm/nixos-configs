{
  lib,
  fetchFromGitHub,
  fetchPypi,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  python313,
  makeWrapper,
  writeShellScript,
  nix-update-script,
}:
let
  python = python313.override {
    self = python;
    packageOverrides = pyFinal: _pyPrev: {
      flask-htmx = pyFinal.buildPythonPackage (finalAttrs: {
        pname = "flask-htmx";
        version = "0.4.0";
        pyproject = true;

        src = fetchPypi {
          pname = "flask_htmx";
          inherit (finalAttrs) version;
          hash = "sha256-LTZ/snyNqZ0DGgxWa35WJjcTlyLi1OjsZ8f5Qa3bIv0=";
        };

        # poetry-core renders `^2.0.2 || ^3.0.0` as an invalid Requires-Dist
        # ("Flask (>=2.0.2,<3.0.0 || >=3.0.0,<4.0.0)") that packaging >= 26 rejects.
        # Same range, written so it serialises cleanly.
        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail 'Flask = "^2.0.2 || ^3.0.0"' 'Flask = ">=2.0.2,<4.0.0"'
        '';

        build-system = [ pyFinal.poetry-core ];
        dependencies = [ pyFinal.flask ];

        pythonImportsCheck = [ "flask_htmx" ];

        meta = {
          description = "Flask extension to work with HTMX";
          homepage = "https://github.com/edmondchuc/flask-htmx";
          license = lib.licenses.mit;
        };
      });
    };
  };
in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "wizarr";
  version = "2026.10.1";
  # Upstream's pyproject.toml has no build backend; it's run from a source checkout (see their Dockerfile), so install the tree as-is.
  pyproject = false;

  src = fetchFromGitHub {
    owner = "Wizarrrr";
    repo = "wizarr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VZpPqF6XJjWMGKTrLiiSQCB4Dlj+Ca0GAXboy6P7dT0=";
  };

  patches = [
    # Upstream hardcodes its state dir to /data/database (if /data exists) or a directory inside the source tree, which is read-only in the store.
    # Let WIZARR_DATA_DIR override both.
    ./data-dir-env.patch
  ];

  npmRoot = "app/static";
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    sourceRoot = "${finalAttrs.src.name}/app/static";
    hash = "sha256-OOjMPrlNgkAWc7oqoE5b6JPA4voIZEDf2F9kFTj8Gjk=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    npmHooks.npmConfigHook
    python.pkgs.babel
    python.pkgs.wrapPython
  ];

  # Mirrors [project].dependencies in upstream's pyproject.toml.
  dependencies = with python.pkgs; [
    apprise
    cachetools
    cryptography
    email-validator
    flask
    flask-apscheduler
    flask-babel
    flask-compress
    flask-htmx
    flask-limiter
    flask-login
    flask-migrate
    flask-restx
    flask-session
    flask-sqlalchemy
    flask-wtf
    gunicorn
    jinja2
    ldap3
    markdown
    packaging
    plexapi
    pyjwt
    python-dotenv
    python-frontmatter
    pyyaml
    requests
    setuptools
    sqlalchemy
    structlog
    webauthn
    websocket-client
    wtforms
  ];

  buildPhase = ''
    runHook preBuild

    # Include fuzzy entries, matching upstream's Dockerfile.
    pybabel compile --use-fuzzy -d app/translations

    pushd app/static
    DOCKER_BUILD=true npm run build
    rm -rf node_modules
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/wizarr
    cp -r app migrations wizard_steps run.py gunicorn.conf.py $out/libexec/wizarr/

    runHook postInstall
  '';

  dontWrapPythonPrograms = true;

  # Wrappers are made here rather than in installPhase so buildPythonPath can
  # read $out's propagated dependencies, which fixupPhase has written by now.
  postFixup =
    let
      start_script = writeShellScript "start-wizarr" ''
        exec ${lib.getExe python.pkgs.gunicorn} --config gunicorn.conf.py --umask 007 "$@" run:app
      '';
      init_db = writeShellScript "init-wizarr-db" ''
        FLASK_SKIP_SCHEDULER=true exec ${lib.getExe python.pkgs.flask} db upgrade
      '';
    in
    ''
      buildPythonPath "$out $pythonPath"

      local _commonArgs=(
        --chdir "$out/libexec/wizarr"
        --set PYTHONPATH "$out/libexec/wizarr:$program_PYTHONPATH"
        --set-default FLASK_ENV production
        --set-default FLASK_APP run.py
        --set-default APP_VERSION "${finalAttrs.version}"
      )

      makeWrapper ${start_script} $out/bin/wizarr "''${_commonArgs[@]}"
      makeWrapper ${init_db} $out/libexec/init-db "''${_commonArgs[@]}"
    '';

  passthru = {
    inherit python;
    updateScript = nix-update-script { extraArgs = [ "--flake" ]; };
  };

  meta = {
    description = "Multi-server invitation manager for Plex, Jellyfin, Emby and Audiobookshelf";
    homepage = "https://github.com/Wizarrrr/wizarr";
    changelog = "https://github.com/Wizarrrr/wizarr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mistyttm ];
    platforms = lib.platforms.linux;
    mainProgram = "wizarr";
  };
})
