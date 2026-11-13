{config, ...}: let
  inherit (config.doggate.ci) steps;
  script = config.doggate.ci.script "deploy-foodbowl";
in {
  perSystem = perSystem: {
    githubActions.workflows.deploy-foodbowl = {
      name = "Deploy foodbowl";

      on = {
        workflowRun = {
          workflows = [perSystem.config.githubActions.workflows.build.name];
          types = ["completed"];
          branches = ["main"];
        };
        workflowDispatch = {};
      };

      permissions.contents = "read";

      jobs.deploy = {
        name = "Switch foodbowl to the cached build";
        # A failed build run can still have cached foodbowl; deploy.sh refuses to build if not.
        if_ = "github.event_name == 'workflow_dispatch' || (github.event.workflow_run.event != 'pull_request' && github.event.workflow_run.conclusion != 'cancelled')";
        runsOn = "ubuntu-latest";
        timeoutMinutes = 60;
        concurrency = {
          group = "deploy-foodbowl";
          cancelInProgress = false;
        };
        steps = [
          (steps.checkout // {with_.ref = "\${{ github.event.workflow_run.head_sha || github.sha }}";})
          (steps.installLix ["max-jobs = 0"])
          {
            name = "Configure SSH";
            shell = "bash";
            env = {
              DEPLOY_KEY = "\${{ secrets.FOODBOWL_DEPLOY_KEY }}";
              KNOWN_HOSTS = "\${{ secrets.FOODBOWL_KNOWN_HOSTS }}";
            };
            run = script "ssh-setup";
          }
          {
            name = "Switch foodbowl";
            shell = "bash";
            run = script "deploy";
          }
          {
            name = "Clean old generations";
            shell = "bash";
            run = script "clean";
          }
        ];
      };
    };
  };
}
