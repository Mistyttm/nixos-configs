# After editing modules/ci, run `nix run .#write-workflows` and commit the result.
{
  inputs,
  lib,
  self,
  ...
}: {
  flake-file.inputs.github-actions-nix = {
    url = "github:synapdeck/github-actions-nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  imports = [inputs.github-actions-nix.flakeModule];

  perSystem = {
    config,
    pkgs,
    ...
  }: let
    files = config.githubActions.workflowFiles;
  in {
    githubActions.enable = true;

    apps.write-workflows = {
      type = "app";
      meta.description = "Write the Nix-defined GitHub workflows to .github/workflows";
      program = lib.getExe (pkgs.writeShellApplication {
        name = "write-workflows";
        runtimeInputs = [pkgs.git];
        text = ''
          dir="$(git rev-parse --show-toplevel)/.github/workflows"
          mkdir -p "$dir"
          ${lib.concatStrings (lib.mapAttrsToList (name: file: ''
              install -m 644 ${file} "$dir/${name}"
              echo "wrote .github/workflows/${name}"
            '')
            files)}
        '';
      });
    };

    checks.github-workflows = pkgs.runCommandLocal "github-workflows-up-to-date" {} ''
      status=0
      ${lib.concatStrings (lib.mapAttrsToList (name: file: ''
          if ! diff -u ${self}/.github/workflows/${name} ${file}; then
            echo ".github/workflows/${name} is out of date: run 'nix run .#write-workflows'" >&2
            status=1
          fi
        '')
        files)}
      [ "$status" -eq 0 ] && touch $out
      exit "$status"
    '';

    pre-commit.settings.hooks.github-workflows-sync = {
      enable = true;
      name = "GitHub workflows sync check";
      entry = "bash -c 'nix run .#write-workflows && git diff --quiet -- .github/workflows || (echo \"GitHub workflows are out of sync: run nix run .#write-workflows\" && exit 1)'";
      files = "^(modules/ci/.*|\\.github/workflows/.*)$";
      pass_filenames = false;
    };
  };
}
