{
  lib,
  stdenv,
  fetchFromGitHub,
  python313,
  ffmpeg,
  streamlink,
  postgresql,
  makeWrapper,
}:
let
  pythonEnv = python313.withPackages (
    ps: with ps; [
      django
      psycopg2
      celery
      redis
      djangorestframework
      requests
      psutil
      pillow
      drf-spectacular
      yt-dlp
      gevent
      daphne
      django-cors-headers
      djangorestframework-simplejwt
      m3u8
      rapidfuzz
      regex
      tzlocal
      pytz
      channels
      channels-redis
      django-filter
      django-celery-beat
      lxml
      packaging
      gunicorn
    ]
  );

  runtimePath = lib.makeBinPath [
    ffmpeg
    streamlink
  ];

  dispatcharr-frontend = lib.callPackage ./dispatcharr-frontend.nix;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dispatcharr";
  version = "0.20.2";

  src = fetchFromGitHub {
    owner = "Dispatcharr";
    repo = "Dispatcharr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZK65rJYgAyzS1lQdzlxrw31qfsjxcDi8xuDr+JWVlhw=";
  };

  nativeBuildInputs = [
    makeWrapper
    pythonEnv
    python313
  ];

  buildInputs = [
    ffmpeg
    streamlink
    postgresql.lib
  ];

  buildPhase = ''
    runHook preBuild

    export DJANGO_SETTINGS_MODULE=dispatcharr.settings
    export DJANGO_SECRET_KEY="build-only-placeholder-key"
    export DB_ENGINE=sqlite
    export REDIS_HOST=localhost
    ${pythonEnv}/bin/python manage.py collectstatic --noinput || true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/dispatcharr
    cp -r apps core dispatcharr fixtures.json manage.py version.py pyproject.toml $out/share/dispatcharr/

    mkdir -p $out/share/dispatcharr/frontend
    cp -r ${dispatcharr-frontend}/dist $out/share/dispatcharr/frontend/

    if [ -d static ]; then
      cp -r static $out/share/dispatcharr/
    fi

    if [ -d templates ]; then
      cp -r templates $out/share/dispatcharr/
    fi

    mkdir -p $out/bin

    local _commonArgs=(
      --chdir "$out/share/dispatcharr"
      --prefix PATH : "${runtimePath}"
      --set PYTHONPATH "$out/share/dispatcharr"
      --set DJANGO_SETTINGS_MODULE dispatcharr.settings
    )

    makeWrapper ${pythonEnv}/bin/gunicorn $out/bin/dispatcharr-gunicorn \
      "''${_commonArgs[@]}" \
      --add-flags "--workers=4" \
      --add-flags "--worker-class=gevent" \
      --add-flags "--timeout=300" \
      --add-flags "dispatcharr.wsgi:application"

    makeWrapper ${pythonEnv}/bin/daphne $out/bin/dispatcharr-daphne \
      "''${_commonArgs[@]}" \
      --add-flags "dispatcharr.asgi:application"

    makeWrapper ${pythonEnv}/bin/celery $out/bin/dispatcharr-celery \
      "''${_commonArgs[@]}" \
      --add-flags "-A dispatcharr worker"

    makeWrapper ${pythonEnv}/bin/celery $out/bin/dispatcharr-celerybeat \
      "''${_commonArgs[@]}" \
      --add-flags "-A dispatcharr beat"

    makeWrapper ${pythonEnv}/bin/python $out/bin/dispatcharr-manage \
      "''${_commonArgs[@]}" \
      --add-flags "$out/share/dispatcharr/manage.py"

    runHook postInstall
  '';

  passthru = {
    frontend = dispatcharr-frontend;
  };

  meta = {
    description = "IPTV stream management and dispatching service";
    homepage = "https://github.com/Dispatcharr/Dispatcharr";
    license = lib.licenses.cc-by-nc-sa-40;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "dispatcharr-gunicorn";
  };
})
