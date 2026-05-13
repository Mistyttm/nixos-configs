{ inputs, ... }:
{
  flake.overlays.default =
    final: prev:
    prev.lib.filesystem.packagesFromDirectoryRecursive {
      callPackage = prev.callPackage;
      directory = ../packages;
    };

  perSystem =
    { pkgs, ... }:
    {
      packages = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
        callPackage = pkgs.callPackage;
        directory = ../packages;
      };
    };
}
