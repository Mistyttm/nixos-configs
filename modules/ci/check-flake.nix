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
