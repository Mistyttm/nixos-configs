# .github/workflows/build.yml: build every NixOS system and push to Cachix.
#
# Step scripts live in ./build/*.sh and are inlined verbatim; shared steps
# and the host matrix come from ./helpers.nix (config.doggate.ci).
{
  config,
  lib,
  ...
}: let
  inherit (config.doggate.ci) steps systems;
  script = config.doggate.ci.script "build";

  # Shared derivations can only be shared within one architecture, so plan per
  # architecture and skip any with a single system (nothing to share).
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
          # Follows update-flake.nix, so renaming that workflow cannot break this.
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

          # Stage 2: per-system builds, each on a native runner. Everything
          # shared is already in Cachix. Skipped if build-shared failed
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
          # Stage 1: build every derivation that more than one system needs,
          # exactly once, and push it to Cachix. Otherwise each matrix job starts
          # with an empty store and shared derivations (custom packages, kernels,
          # etc.) get built once per system in parallel.
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
                  # Stay under the 360 minute job limit so the push and log
                  # steps still run. Cachix pushes paths as they finish.
                  timeoutMinutes = 320;
                  shell = "bash";
                  run = script "build-shared";
                }
                # The cachix daemon already pushes each path as it is built;
                # this is an explicit second push so the cache is complete
                # before stage 2 starts.
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
