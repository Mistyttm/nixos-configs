inputs: let
  of = inputs.omniflake.flakes;
  modules = of.import-tree ./modules;
in
  of.flake-parts.lib.mkFlake {inherit inputs;} {
    imports = [
      modules
      of.home-manager.flakeModules.home-manager
      of.git-hooks-nix.flakeModule
      of.mkdocs-flake.flakeModule
      of.devshell.flakeModule
      of.nix-topology.flakeModule
      of.pkgs-by-name-for-flake-parts.flakeModule
    ];
  }
