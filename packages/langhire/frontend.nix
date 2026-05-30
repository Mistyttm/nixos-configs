{
  buildNpmPackage,
  src,
}:
buildNpmPackage {
  pname = "langhire-frontend";
  version = "1.0.0";
  inherit src;

  npmRoot = ".";
  npmDepsFetcherVersion = 2;
  makeCacheWritable = true;
  npmDepsHash = "sha256-X/07JR9dOz221GSEGhqCodazH6F6GFiY0FOfi2iOyxA=";
  npmFlags = [ "--legacy-peer-deps" ];
  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/langhire/frontend
    cp -r dist $out/share/langhire/frontend/
    runHook postInstall
  '';
}
