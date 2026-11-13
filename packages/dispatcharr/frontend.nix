{
  lib,
  buildNpmPackage,
  src,
  version,
}:
buildNpmPackage (finalAttrs: {
  pname = "dispatcharr-frontend";
  inherit src version;

  __structuredAttrs = true;

  sourceRoot = "${finalAttrs.src.name}/frontend";

  npmDepsHash = "sha256-pcuG3d9PSB/wgNM+53kT+5T6Xj/gRQqnbIoaSRu1Mms=";
  npmDepsFetcherVersion = 2;
  # webworkify-webpack (via mpegts.js) is a git dependency without a lockfile.
  forceGitDeps = true;
  # npm's git-dep prepare step reads these from the environment, which __structuredAttrs doesn't export.
  postPatch = "export forceGitDeps stdenv";
  makeCacheWritable = true;

  installPhase = ''
    runHook preInstall
    cp -r dist $out
    runHook postInstall
  '';

  meta = {
    description = "Web frontend for Dispatcharr";
    homepage = "https://github.com/Dispatcharr/Dispatcharr";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ mistyttm ];
    platforms = lib.platforms.all;
  };
})
