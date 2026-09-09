{inputs, ...}: {
  imports = [inputs.omniflake.flakes.pkgs-by-name-for-flake-parts.flakeModule];

  flake.overlays.default = _final: prev: let
    pkgsDir = ../packages;
  in
    builtins.mapAttrs
    (name: _: prev.callPackage (pkgsDir + "/${name}/package.nix") {})
    (builtins.readDir pkgsDir);

  perSystem = {system, ...}: {
    pkgsDirectory = ../packages;

    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [inputs.self.overlays.default];
    };
  };
}
