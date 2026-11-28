{
  tackOverrides ? {},
  flakeSelf ? null,
}: let
  rawInputs = (import ./.tack) {overrides = tackOverrides;};

  # tack has no `self` input, but flake-parts needs one that carries the
  # outputs and the real source path.
  inputs = rawInputs // {self = self';};
  self' =
    outputs
    // {
      inherit inputs;
      outPath =
        if flakeSelf != null
        then flakeSelf.outPath
        else ./.;
    };

  modules = rawInputs.import-tree ./modules;

  outputs = rawInputs.flake-parts.lib.mkFlake {inherit inputs;} {
    imports = [
      modules
      inputs.home-manager.flakeModules.home-manager
      inputs.git-hooks-nix.flakeModule
      inputs.mkdocs-flake.flakeModule
      inputs.devshell.flakeModule
      inputs.nix-topology.flakeModule
    ];
  };
in
  outputs
