{
  config,
  lib,
  ...
}: let
  inherit (config.doggate.ci) steps systems;
  script = config.doggate.ci.script "build";

  # Derivations can only be shared within one architecture.
  sharedGroups = lib.filter (group: lib.length group.systems > 1) (
    lib.mapAttrsToList (arch: members: {
      inherit arch;
      inherit (lib.head members) runner;
      systems = map (member: member.system) members;
    }) (lib.groupBy (entry: entry.arch) systems)
  );
  hasShared = sharedGroups != [];
in {
  perSystem = perSystem: {
    githubActions.workflows.build = {
      name = "Build and Cache NixOS Systems";

      on = {
        workflowRun = {
          workflows = [perSystem.config.githubActions.workflows.update-flake.name];
          types = ["completed"];
          branches = ["main"];
        };
        pullRequest.paths = ["flake.lock"];
        workflowDispatch = {};
      };

      permissions = {
        contents = "read";
        id-token = "write";
      };

      jobs =
        {
          evaluate = {
            name = "Evaluate Flake";
            if_ = "github.event_name != 'workflow_run' || github.event.workflow_run.conclusion == 'success'";
            runsOn = "ubuntu-latest";
            steps =
              [steps.checkout]
              ++ steps.maximizeDiskSpace null
              ++ [
                (steps.installLix [])
                {
                  name = "Evaluate Hydra jobs";
                  id = "eval";
                  shell = "bash";
                  run = script "evaluate";
                }
              ];
          };

          build = {
            name = "Build \${{ matrix.system }} (\${{ matrix.arch }})";
            needs = ["evaluate"] ++ lib.optional hasShared "build-shared";
            if_ = lib.concatStringsSep " && " (
              [
                "!cancelled()"
                "needs.evaluate.result == 'success'"
              ]
              ++ lib.optional hasShared "(needs.build-shared.result == 'success' || needs.build-shared.result == 'skipped')"
            );
            strategy = {
              failFast = false;
              matrix.include = systems;
            };
            runsOn = "\${{ matrix.runner }}";
            timeoutMinutes = 360;
            steps =
              [steps.checkout]
              ++ steps.maximizeDiskSpace "matrix.arch"
              ++ [(steps.installLix ["max-jobs = 2"])]
              ++ steps.caches
              ++ [
                {
                  name = "Build \${{ matrix.system }}";
                  id = "build";
                  shell = "bash";
                  env.SYSTEM = "\${{ matrix.system }}";
                  run = script "build-system";
                }
                {
                  name = "Summarise build failure";
                  if_ = "(failure() || cancelled()) && steps.build.outcome != 'success'";
                  shell = "bash";
                  env.SYSTEM = "\${{ matrix.system }}";
                  run = script "summarise-build";
                }
                {
                  name = "Upload build logs";
                  if_ = "failure() || cancelled()";
                  uses = "actions/upload-artifact@v4";
                  with_ = {
                    name = "nix-build-log-\${{ matrix.system }}";
                    path = "build-results/build.jsonl";
                  };
                }
                steps.diskUsage
              ];
          };
        }
        // lib.optionalAttrs hasShared {
          # Builds what 2+ systems need once, instead of once per matrix job.
          build-shared = {
            name = "Build shared derivations (\${{ matrix.group.arch }})";
            needs = ["evaluate"];
            strategy = {
              failFast = false;
              matrix.group = sharedGroups;
            };
            runsOn = "\${{ matrix.group.runner }}";
            timeoutMinutes = 360;
            env.SYSTEMS = "\${{ toJSON(matrix.group.systems) }}";
            steps =
              [steps.checkout]
              ++ steps.maximizeDiskSpace "matrix.group.arch"
              ++ [(steps.installLix ["max-jobs = 2"])]
              ++ steps.caches
              ++ [
                {
                  name = "Plan shared derivations";
                  id = "plan";
                  shell = "bash";
                  run = script "plan-shared";
                }
                {
                  name = "Build shared derivations";
                  id = "build";
                  if_ = "steps.plan.outputs.shared != '0'";
                  # Leaves time for the push and log steps within the job limit.
                  timeoutMinutes = 320;
                  shell = "bash";
                  run = script "build-shared";
                }
                # Explicit push so the cache is complete before the per-system jobs.
                {
                  name = "Push built shared derivations to Cachix";
                  if_ = "!cancelled() && steps.plan.outputs.shared != '0'";
                  shell = "bash";
                  env.CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                  run = script "push-shared";
                }
                {
                  name = "Summarise shared build failure";
                  if_ = "failure() && steps.build.outcome == 'failure'";
                  shell = "bash";
                  run = script "summarise-shared";
                }
                {
                  name = "Upload shared build logs";
                  if_ = "failure()";
                  uses = "actions/upload-artifact@v4";
                  with_ = {
                    name = "nix-build-log-shared-\${{ matrix.group.arch }}";
                    path = ''
                      build-results/build-shared.log
                      build-results/dryrun.log
                    '';
                  };
                }
                steps.diskUsage
              ];
          };
        };
    };
  };
}
