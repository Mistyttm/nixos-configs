{
  lib,
  buildDotnetModule,
  fetchgit,
  dotnetCorePackages,
  perl,
}:
buildDotnetModule (_finalAttrs: {
  pname = "transmission-api-rpc";
  # Upstream doesn't tag releases; this matches the AssemblyName/Version
  # pinned in the fork's own csproj (and what Cleanuparr's PackageReference
  # expects).
  version = "1.0.3";

  src = fetchgit {
    url = "https://github.com/Cleanuparr/Transmission.API.RPC.git";
    rev = "HEAD";
    hash = "sha256-JFmTyRzHN3fDdZOoeFz89fk7kroT33tceoUpVBoWS5g=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  projectFile = "Transmission.API.RPC/Transmission.API.RPC.csproj";

  # Generate/refresh this with:
  #   nix build .#transmission-api-rpc.fetch-deps
  #   ./result ./transmission-api-rpc-deps.json
  nugetDeps = ./transmission-api-rpc-deps.json;

  nativeBuildInputs = [perl];

  postPatch = ''
    # Bump the ancient netstandard2.1 TFM so it plays nicely restoring
    # alongside the net10.0 main project.
    perl -0777 -pi -e 's/<TargetFrameworks?>[\s\S]*?<\/TargetFrameworks?>/<TargetFramework>net10.0<\/TargetFramework>/g' \
      Transmission.API.RPC/Transmission.API.RPC.csproj

    # These meta-packages are long since folded into the BCL and conflict
    # with net10.0 targets.
    perl -0777 -pi -e 's/<PackageReference\s+[^>]*Include="System\.[^"]*"[\s\S]*?(?:\/>|<\/PackageReference>)//g' \
      Transmission.API.RPC/Transmission.API.RPC.csproj
  '';

  # This is a library dependency, not an app - we only want the .nupkg.
  dontPublish = true;
  packNupkg = true;

  meta = {
    description = "Transmission RPC client library (Cleanuparr fork), packed for use as a local NuGet dependency";
    homepage = "https://github.com/Cleanuparr/Transmission.API.RPC";
    license = lib.licenses.mit; # confirm against upstream LICENSE
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
