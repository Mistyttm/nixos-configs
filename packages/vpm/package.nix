{
  lib,
  buildDotnetGlobalTool,
}:
buildDotnetGlobalTool {
  pname = "vpm";
  version = "0.1.28";

  nugetName = "vrchat.vpm.cli";

  nugetHash = "sha256-Pz8KBpjmpzx+6gD4nqGVBEp5z4UX6hFqZHGy8hJCD4k=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "VRChat Package Manager CLI";
    homepage = "https://vcc.docs.vrchat.com/vpm/cli";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "vpm";
  };
}
