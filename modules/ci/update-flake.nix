# .github/workflows/update-flake.yml: update flake.lock every 12 hours and push
# it to main. A successful run triggers build.yml (see build.nix), which reads
# this workflow's `name` from here rather than repeating it.
#
# Step scripts live in ./update-flake/*.sh; shared steps come from
# ./helpers.nix (config.doggate.ci).
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
          {
            name = "Configure Git";
            run = ''
              git config user.name "github-actions[bot]"
              git config user.email "github-actions[bot]@users.noreply.github.com"
            '';
          }
          (steps.installLix [
            "max-jobs = auto"
            "cores = 0"
            "substitute = true"
            "builders ="
          ])
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
