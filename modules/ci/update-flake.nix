{
  config,
  lib,
  ...
}: let
  inherit (config.doggate.ci) steps;
  script = config.doggate.ci.script "update-flake";

  # cron -> tack groups updated by that schedule (times are UTC)
  cadences = {
    "0 */12 * * *" = ["core" "system"];
    "0 4 * * *" = ["desktop" "server"];
    "0 4 * * 1" = ["tooling"];
  };
  groups = lib.concatLists (lib.attrValues cadences);

  # a pin outside every scheduled group would never be updated by CI
  ungrouped = lib.attrNames (
    lib.filterAttrs (_: input: !(lib.elem input.group groups)) config.flake-file.inputs
  );
in {
  perSystem = _: {
    githubActions.workflows.update-flake = lib.throwIf (ungrouped != []) "update-flake: inputs ${lib.concatStringsSep ", " ungrouped} need a `group` from: ${lib.concatStringsSep ", " groups}" {
      name = "Update Flake Inputs";

      on = {
        schedule = map (cron: {inherit cron;}) (lib.attrNames cadences);
        workflowDispatch.inputs.groups = {
          description = "tack group to update";
          type = "choice";
          options = ["all"] ++ groups;
          default = "all";
        };
      };

      # runs push to main, so never let two overlap
      concurrency = {
        group = "update-flake";
        cancelInProgress = false;
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
            name = "Update tack pins";
            id = "update";
            env = {
              GITHUB_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
              CADENCES = builtins.toJSON cadences;
              EVENT_SCHEDULE = "\${{ github.event.schedule }}";
              DISPATCH_GROUPS = "\${{ inputs.groups }}";
            };
            run = script "update";
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
          {
            name = "Report failed groups";
            if_ = "steps.update.outputs.failed != ''";
            env.FAILED = "\${{ steps.update.outputs.failed }}";
            run = ''
              echo "::error::tack update failed for: $FAILED"
              exit 1
            '';
          }
        ];
      };
    };
  };
}
