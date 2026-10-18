inputs: let
  modules = inputs.import-tree ./modules;
in
  inputs.flake-parts.lib.mkFlake {inherit inputs;} {
    imports = [
      modules
      inputs.home-manager.flakeModules.home-manager
      inputs.git-hooks-nix.flakeModule
      inputs.mkdocs-flake.flakeModule
      inputs.devshell.flakeModule
      inputs.nix-topology.flakeModule
      inputs.pkgs-by-name-for-flake-parts.flakeModule
    ];
  }
