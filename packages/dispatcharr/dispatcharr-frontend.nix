{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "dispatcharr-frontend";
  version = "0.20.2";

  src = fetchFromGitHub {
    owner = "Dispatcharr";
    repo = "Dispatcharr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZK65rJYgAyzS1lQdzlxrw31qfsjxcDi8xuDr+JWVlhw=";
  };

  sourceRoot = "${finalAttrs.src.name}/frontend";

  npmDepsHash = "sha256-vgzRWaPntQMN/VK6brC7TwDiG4Vw1YHccADJQWiv1mY=";

  makeCacheWritable = true;
  forceGitDeps = true;

  NODE_OPTIONS = "--max-old-space-size=4096";
  npmFlags = [ "--legacy-peer-deps" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r dist $out/
    runHook postInstall
  '';

  meta = {
    description = "Frontend for Dispatcharr IPTV stream management service";
    homepage = "https://github.com/Dispatcharr/Dispatcharr";
    license = lib.licenses.cc-by-nc-sa-40;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
