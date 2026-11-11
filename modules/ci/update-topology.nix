{config, ...}: let
  inherit (config.doggate.ci) steps;
  script = config.doggate.ci.script "update-topology";
in {
  perSystem = _: {
    githubActions.workflows.update-topology = {
      name = "Update Topology Diagrams";

      on = {
        push = {
          branches = ["main"];
          paths = ["modules/**"];
        };
        workflowDispatch = {};
      };

      jobs.update-topology = {
        name = "Generate topology diagrams";
        runsOn = "ubuntu-latest";
        permissions = {
          contents = "write";
          id-token = "write";
        };
        steps = [
          steps.checkout
          steps.configureGit
          (steps.installLix config.doggate.ci.allCoresNixConfig)
          steps.magicNixCache
          {
            name = "Build topology diagrams";
            run = script "update-svgs";
          }
          {
            name = "Check for changes";
            id = "check_changes";
            run = script "check-changes";
          }
          {
            name = "Commit and push changes";
            if_ = "steps.check_changes.outputs.changed == 'true'";
            run = script "commit-push";
          }
        ];
      };
    };
  };
}
