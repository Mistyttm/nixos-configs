{config, ...}: let
  inherit (config.doggate.ci) steps;
in {
  perSystem = _: {
    githubActions.workflows.update-workflows = {
      name = "Update GitHub Workflows";

      on = {
        push = {
          branches = ["main"];
          paths = [
            "modules/**"
            "packages/**"
            "outputs.nix"
            "flake.nix"
            ".tack/pins.lock.json"
            ".github/workflows/**"
          ];
        };
        schedule = [{cron = "17 5 * * 1";}];
        workflowDispatch = {};
      };

      jobs.update-workflows = {
        runsOn = "ubuntu-latest";
        permissions.contents = "write";
        steps = [
          steps.checkout
          steps.configureGit
          (steps.installLix [])
          {
            name = "Regenerate workflows";
            run = ''
              nix run .#write-workflows

              if [ -z "$(git status --porcelain -- .github/workflows)" ]; then
                echo "GitHub workflows are already up to date"
                exit 0
              fi

              git add -A .github/workflows
              git commit -m "chore(ci): regenerate GitHub workflows [skip ci]"
              git push origin "HEAD:''${GITHUB_REF_NAME}"
            '';
          }
        ];
      };
    };
  };
}
