# .github/workflows/update-packages.yml: every 3 days, run each local package's
# update script and land the result.
#
# A package under packages/ is updated if it defines `passthru.updateScript`
# (nixpkgs' convention). Whether it is free or unfree comes from its
# meta.license. Both are worked out here when the workflow is generated, so
# there is no list to keep in sync: add an updateScript, run
# `nix run .#write-workflows`, and the package is picked up.
#
# - Free packages are built in CI
# - Unfree packages are never built in CI; every update opens a PR for
#   manual testing.
#
# Step scripts live in ./update-packages/*.sh; shared steps come from
# ./helpers.nix (config.doggate.ci).
{
  config,
  lib,
  self,
  ...
}: let
  inherit (config.doggate.ci) steps;
  script = config.doggate.ci.script "update-packages";

  # The jobs update and build `packages.x86_64-linux.<name>`.
  packageSet = self.packages.x86_64-linux;

  # Only the packages defined in packages/
  updatable =
    lib.filter (name: packageSet ? ${name} && packageSet.${name} ? updateScript)
    (lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../../packages)));

  isUnfree = name: lib.any (license: !(license.free or true)) (lib.toList (packageSet.${name}.meta.license or []));

  # Steps shared by the free and unfree jobs: update the package and work out
  # its commit message. Later steps read `steps.update_package.outputs.changed`
  # and `steps.commit_message.outputs.message`.
  updateSteps = [
    (lib.recursiveUpdate steps.checkout {
      with_ = {
        fetch-depth = 0;
        token = "\${{ secrets.GITHUB_TOKEN }}";
      };
    })
    steps.configureGit
    (steps.installLix [
      "max-jobs = auto"
      "cores = 0"
      "substitute = true"
      "builders ="
    ])
    steps.magicNixCache
    # Pull from Cachix, but only push after a successful build (see build.sh).
    (lib.recursiveUpdate steps.cachix {with_.skipPush = true;})
    {
      name = "Update package version";
      id = "update_package";
      env.PACKAGE = "\${{ matrix.package }}";
      run = script "update";
    }
    {
      name = "Prepare commit message";
      id = "commit_message";
      if_ = "steps.update_package.outputs.changed == 'true'";
      env.PACKAGE = "\${{ matrix.package }}";
      run = script "commit-message";
    }
  ];

  # Open (or update) the PR for a package update.
  openPullRequest = {
    name,
    if_,
    body,
  }: {
    inherit name if_;
    uses = "peter-evans/create-pull-request@v7";
    with_ = {
      token = "\${{ secrets.GITHUB_TOKEN }}";
      branch = "bot/package-update-\${{ matrix.package }}-build-failure";
      delete-branch = false;
      title = "\${{ steps.commit_message.outputs.message }}";
      commit-message = "\${{ steps.commit_message.outputs.message }}";
      inherit body;
      add-paths = "packages/\${{ matrix.package }}";
    };
  };

  updateJob = packages: extraSteps: {
    runsOn = "ubuntu-latest";
    strategy = {
      failFast = false;
      matrix.package = packages;
    };
    steps = updateSteps ++ extraSteps;
  };
in {
  perSystem = _: {
    githubActions.workflows.update-packages = {
      name = "Update Local Packages";

      on = {
        # Every 3 days at 03:00 UTC.
        schedule = [{cron = "0 3 */3 * *";}];
        workflowDispatch = {};
      };

      permissions = {
        contents = "write";
        pull-requests = "write";
        id-token = "write";
      };

      concurrency = {
        group = "update-local-packages";
        cancelInProgress = true;
      };

      # A job with no packages is left out entirely.
      jobs =
        lib.optionalAttrs (lib.any (name: !isUnfree name) updatable) {
          update-free-package = updateJob (lib.filter (name: !isUnfree name) updatable) [
            {
              name = "Build updated package";
              id = "build_package";
              if_ = "steps.update_package.outputs.changed == 'true'";
              env.PACKAGE = "\${{ matrix.package }}";
              run = script "build";
            }
            {
              name = "Commit and push package update";
              if_ = "steps.update_package.outputs.changed == 'true' && steps.build_package.outputs.package_failed != 'true'";
              env = {
                PACKAGE = "\${{ matrix.package }}";
                COMMIT_MESSAGE = "\${{ steps.commit_message.outputs.message }}";
              };
              run = script "commit-push";
            }
            {
              name = "Upload build log on failure";
              if_ = "steps.update_package.outputs.changed == 'true' && steps.build_package.outputs.package_failed == 'true'";
              uses = "actions/upload-artifact@v4";
              with_ = {
                name = "package-build-log-\${{ matrix.package }}";
                path = ''
                  build.log
                  build.json
                '';
                if-no-files-found = "ignore";
                retention-days = 14;
              };
            }
            (openPullRequest {
              name = "Open PR on build failure";
              if_ = "steps.update_package.outputs.changed == 'true' && steps.build_package.outputs.package_failed == 'true'";
              body = ''
                Automated update for `''${{ matrix.package }}` encountered a build failure.

                ''${{ steps.build_package.outputs.failure_summary }}

                ```text
                ''${{ steps.build_package.outputs.failure_log_excerpt }}
                ```

                Full logs are available as workflow artifact `package-build-log-''${{ matrix.package }}`.
              '';
            })
          ];
        }
        // lib.optionalAttrs (lib.any isUnfree updatable) {
          update-unfree-package = updateJob (lib.filter isUnfree updatable) [
            (openPullRequest {
              name = "Open PR for manual testing";
              if_ = "steps.update_package.outputs.changed == 'true'";
              body = ''
                Automated update for unfree package `''${{ matrix.package }}`.

                Package is marked unfree, so CI does not build it. Opened as a PR for manual testing.
              '';
            })
          ];
        };
    };
  };
}
