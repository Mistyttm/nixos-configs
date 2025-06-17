{ buildDotnetGlobalTool, lib }:
buildDotnetGlobalTool {
  pname = "vpm";
  version = "0.1.28";

  nugetName = "vrchat.vpm.cli";

  nugetSha256 = "sha256-Pz8KBpjmpzx+6gD4nqGVBEp5z4UX6hFqZHGy8hJCD4k=";

  meta = with lib; {
    description = "VRChat Package Manager CLI";
    maintainers = with maintainers; [ mistyttm ];
    homepage = "https://vcc.docs.vrchat.com/vpm/cli";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
