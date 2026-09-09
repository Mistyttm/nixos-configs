{inputs, ...}: {
  flake-file.inputs.nixpkgs-jellyfin-pr.url = "github:NixOS/nixpkgs/pull/561130/head";

  flake.overlays.jellyfin-12-pr = _final: prev: let
    nixpkgsJellyfinVersion = builtins.head (builtins.match ".*version = \"([^\"]+)\";.*" (builtins.readFile "${inputs.nixpkgs}/pkgs/by-name/je/jellyfin/package.nix"));
    noOverride = prev.lib.versionAtLeast nixpkgsJellyfinVersion "12.0";
  in
    prev.lib.warnIf noOverride
    ''
      jellyfin >= 12.0 is now in nixpkgs — overlays/jellyfin-12-pr.nix (NixOS/nixpkgs#561130) can be deleted.
    ''
    (
      if noOverride
      then {}
      else let
        prPkgs = import inputs.nixpkgs-jellyfin-pr {
          inherit (prev) system;
          inherit (prev) config;
        };
      in {
        inherit (prPkgs) jellyfin jellyfin-web;
      }
    );
}
