final: _prev:
let
  tdarrFixPkgs =
    import
      (builtins.fetchTarball {
        # NixOS/nixpkgs PR #505887 merge commit
        url = "https://github.com/NixOS/nixpkgs/archive/0ac3d6542f40daeac149a3ac65227231f87001b8.tar.gz";
        sha256 = "12xxz7367g64nrxc4ipz9fbsvl9hb7hlqdd0ymr0372wbkll79ix";
      })
      {
        system = final.stdenv.hostPlatform.system;
        config = final.config;
      };
in
{
  tdarr = tdarrFixPkgs.tdarr;
  tdarr-server = tdarrFixPkgs.tdarr-server;
  tdarr-node = tdarrFixPkgs.tdarr-node;
}
