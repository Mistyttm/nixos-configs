# .github/workflows/check-flake.yml: on PRs, fail if a generated file is out of
# sync with the Nix that generates it (flake.nix via flake-file, and the
# workflows in modules/ci/ via github-actions-nix).
#
# Step scripts live in ./check-flake/*.sh; shared steps come from
# ./helpers.nix (config.doggate.ci).
{config, ...}: let
  inherit (config.doggate.ci) steps;
  script = config.doggate.ci.script "check-flake";
in {
  perSystem = _: {
    githubActions.workflows.check-flake = {
      name = "Check flake.nix Sync";

      on = {
        pullRequest.paths = [
          "modules/**.nix"
          "outputs.nix"
          "flake.nix"
          # Workflow step scripts and the generated workflows themselves.
          "modules/ci/**"
          ".github/workflows/**"
        ];
        workflowDispatch = {};
      };

      jobs = {
        check-flake-sync = {
          runsOn = "ubuntu-latest";
          steps = [
            steps.checkout
            (steps.installLix [])
            {
              name = "Regenerate flake.nix and diff";
              run = script "flake-sync";
            }
          ];
        };

        check-workflows-sync = {
          runsOn = "ubuntu-latest";
          steps = [
            steps.checkout
            (steps.installLix [])
            {
              name = "Regenerate workflows and diff";
              run = script "workflows-sync";
            }
          ];
        };
      };
    };
  };
}
