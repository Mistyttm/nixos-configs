{
  lib,
  buildDotnetModule,
  fetchgit,
  dotnetCorePackages,
  perl,
}:
buildDotnetModule (_finalAttrs: {
  pname = "qbittorrent-net-client";
  version = "1.0.3";

  src = fetchgit {
    url = "https://github.com/Cleanuparr/qbittorrent-net-client.git";
    rev = "HEAD";
    hash = "sha256-33M+j8Phukwa5R7zo5Nuc/rSb2Dv2JYfTcXZMkFu7jw=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  projectFile = "src/QBittorrent.Client/QBittorrent.Client.csproj";

  # Generate/refresh this with:
  #   nix build .#qbittorrent-net-client.fetch-deps
  #   ./result ./qbittorrent-net-client-deps.json
  nugetDeps = ./qbittorrent-net-client-deps.json;

  nativeBuildInputs = [perl];

  postPatch = ''
    perl -0777 -pi -e 's/<TargetFrameworks?>[\s\S]*?<\/TargetFrameworks?>/<TargetFramework>net10.0<\/TargetFramework>/g' \
      src/QBittorrent.Client/QBittorrent.Client.csproj

    perl -0777 -pi -e 's/<PackageReference\s+[^>]*Include="System\.[^"]*"[\s\S]*?(?:\/>|<\/PackageReference>)//g' \
      src/QBittorrent.Client/QBittorrent.Client.csproj
  '';

  dontPublish = true;
  packNupkg = true;

  meta = {
    description = "qBittorrent remote API client library (Cleanuparr fork), packed for use as a local NuGet dependency";
    homepage = "https://github.com/Cleanuparr/qbittorrent-net-client";
    license = lib.licenses.mit; # confirm against upstream LICENSE
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
