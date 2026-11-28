{...}: {
  flake-file.inputs.git-hooks-nix = {
    url = "github:cachix/git-hooks.nix";
    group = "tooling";
  };

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;

    pre-commit = {
      # tack-generated resolver
      settings.excludes = ["^\\.tack/"];
      settings.hooks = {
        deadnix = {
          enable = true;
          package = pkgs.deadnix;
          settings = {
            edit = true;
          };
        };
        commitizen.enable = true;
        alejandra = {
          enable = true;
          package = pkgs.alejandra;
        };
      };
    };
  };
}
