{
  inputs,
  lib,
  ...
}: let
  pkgsDir = ../packages;
  pythonPkgsDir = pkgsDir + "/python-packages";

  dirsIn = dir: builtins.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dir));
  topLevelNames = lib.remove "python-packages" (dirsIn pkgsDir);

  callAll = callPackage: dir: names:
    lib.genAttrs names (name: callPackage (dir + "/${name}/package.nix") {});
in {
  flake.overlays.default = _final: prev:
    callAll prev.callPackage pkgsDir topLevelNames
    // {
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [(final: _prev: callAll final.callPackage pythonPkgsDir (dirsIn pythonPkgsDir))];
    };

  perSystem = {
    system,
    pkgs,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [inputs.self.overlays.default];
    };

    packages = lib.genAttrs topLevelNames (name: pkgs.${name});
  };
}
