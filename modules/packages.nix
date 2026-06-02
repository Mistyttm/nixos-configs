{inputs, ...}: {
  imports = [inputs.pkgs-by-name-for-flake-parts.flakeModule];

  flake.overlays.default = final: _prev: let
    pkgsDir = ../packages;
  in
    builtins.mapAttrs
    (name: _: final.callPackage (pkgsDir + "/${name}/package.nix") {})
    (builtins.readDir pkgsDir);

  perSystem = {system, ...}: {
    pkgsDirectory = ../packages;

    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [inputs.self.overlays.default];
    };
  };
}
