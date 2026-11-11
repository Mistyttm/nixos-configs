{config, ...}: let
  inherit (config.doggate.ci) steps;
  script = config.doggate.ci.script "update-flake";
in {
  perSystem = _: {
    githubActions.workflows.update-flake = {
      name = "Update Flake Inputs";

      on = {
        schedule = [{cron = "0 */12 * * *";}];
        workflowDispatch = {};
      };

      jobs.update-flake = {
        runsOn = "ubuntu-latest";
        permissions = {
          contents = "write";
          id-token = "write";
        };
        outputs.changed = "\${{ steps.check_changes.outputs.changed }}";
        steps = [
          (steps.checkout // {with_.token = "\${{ secrets.GITHUB_TOKEN }}";})
          steps.configureGit
          (steps.installLix config.doggate.ci.allCoresNixConfig)
          steps.magicNixCache
          {
            name = "Regenerate flake.nix";
            run = "nix run .#write-flake";
          }
          {
            name = "Update flake inputs";
            run = "nix flake update 2>&1 | tee /tmp/flake-update.log";
          }
          {
            name = "Commit changes";
            run = script "commit";
          }
          {
            name = "Check for changes";
            id = "check_changes";
            run = script "check-changes";
          }
          {
            name = "Push changes";
            if_ = "steps.check_changes.outputs.changed == 'true'";
            run = "git push origin main";
          }
        ];
      };
    };
  };
}
