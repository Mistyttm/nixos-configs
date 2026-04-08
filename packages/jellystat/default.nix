{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "jellystat";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "CyferShepard";
    repo = "Jellystat";
    tag = finalAttrs.version;
    hash = "sha256-M7Gw/TgDB+vA5wtYf5vLxLZ5r9D8B9pVEBE0FiRGlKs=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-JjNYysGfeRD2riQddxqsYPlrg43nC7Vv0B1gi4vX6FE=";

  makeCacheWritable = true;

  nodejs = nodejs_22;

  npmPackFlags = [ "--ignore-scripts" ];
  npmFlags = [ "--legacy-peer-deps" ];

  env.NODE_OPTIONS = "--openssl-legacy-provider";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jellystat $out/bin
    cp -r . $out/share/jellystat/

    makeWrapper ${nodejs_22}/bin/node $out/bin/jellystat \
      --chdir $out/share/jellystat \
      --add-flags $out/share/jellystat/backend/server.js

    runHook postInstall
  '';

  meta = {
    description = "Jellystat is a free and open source Statistics App for Jellyfin";
    homepage = "https://github.com/CyferShepard/Jellystat";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mistyttm ];
    mainProgram = "jellystat";
    platforms = lib.platforms.linux;
  };
})
