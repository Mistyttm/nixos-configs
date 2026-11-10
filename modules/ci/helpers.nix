# Shared building blocks for the Nix-defined GitHub workflows in modules/ci/.
#
# Everything lives under the `doggate.ci` option so each workflow file can read
# it from `config.doggate.ci.*`; helpers refer to each other the same way.
{
  config,
  lib,
  self,
  ...
}: {
  options.doggate.ci = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Values and step builders shared between the generated GitHub workflows.";
  };

  config.doggate.ci = {
    # The flake's own caches, so every nix command on the runner uses them
    nixConfig = lib.concatStringsSep "\n" (
      [
        "experimental-features = nix-command flakes"
        "accept-flake-config = true"
      ]
      ++ lib.mapAttrsToList (name: value: "${name} = ${toString value}") (
        # flake-file.nixConfig has empty defaults (e.g. `substituters = []`);
        # writing those out as `substituters =` would drop cache.nixos.org.
        lib.filterAttrs (_: value: value != null && value != [] && value != "") config.flake-file.nixConfig
      )
    );

    # Read a step script for a workflow: `script "build" "evaluate"` is
    # modules/ci/build/evaluate.sh. Each workflow's scripts live in a folder
    # named after the workflow (its key under githubActions.workflows). They
    # are inlined verbatim, so bash `${var}` and GitHub `${{ ... }}` need no
    # Nix escaping.
    script = workflow: name: builtins.readFile ./${workflow}/${name}.sh;

    # Native runner for each architecture.
    runners = {
      x86_64-linux = "ubuntu-latest";
      aarch64-linux = "ubuntu-24.04-arm";
    };

    # One {system, arch, runner} per NixOS host, computed when the workflows
    # are generated. Adding a host means re-running `nix run .#write-workflows`;
    # the github-workflows check catches it if you forget. A host on an
    # architecture with no runner fails evaluation instead of building on the
    # wrong machine.
    systems = lib.mapAttrsToList (name: cfg: {
      system = name;
      arch = cfg.config.nixpkgs.hostPlatform.system;
      runner =
        config.doggate.ci.runners.${cfg.config.nixpkgs.hostPlatform.system}
        or (throw "doggate.ci: no runner configured for ${cfg.config.nixpkgs.hostPlatform.system} (${name})");
    }) (lib.filterAttrs (name: _: !lib.hasPrefix "thepetshop" name) self.nixosConfigurations);

    steps = {
      checkout = {
        name = "Checkout repository";
        uses = "actions/checkout@v4";
      };

      # Free runner disk space for /nix. `arch` is a GitHub expression for
      # the job's architecture (e.g. "matrix.arch"); null means the job only
      # runs on x86_64.
      maximizeDiskSpace = arch:
        if arch == null
        then [
          {
            name = "Maximize disk space";
            uses = "wimpysworld/nothing-but-nix@main";
            with_.hatchet-protocol = "rampage";
          }
        ]
        else [
          {
            name = "Maximize disk space";
            if_ = "${arch} == 'x86_64-linux'";
            uses = "wimpysworld/nothing-but-nix@main";
            with_ = {
              hatchet-protocol = "rampage";
              root-safe-haven = "8192";
            };
          }
          # 'carve' is the protocol build-isos.yml already uses on the arm runner.
          {
            name = "Maximize disk space (arm)";
            if_ = "${arch} != 'x86_64-linux'";
            uses = "wimpysworld/nothing-but-nix@main";
            with_.hatchet-protocol = "carve";
          }
        ];

      installLix = extra: {
        name = "Install Lix";
        uses = "samueldr/lix-gha-installer-action@latest";
        with_.extra_nix_config = lib.concatStringsSep "\n" ([config.doggate.ci.nixConfig] ++ extra) + "\n";
      };

      magicNixCache = {
        name = "Enable Magic Nix Cache";
        uses = "DeterminateSystems/magic-nix-cache-action@v14";
        with_.use-flakehub = false;
      };

      # Pulls from and pushes everything built to the opinionatedcache Cachix.
      cachix = {
        name = "Setup Cachix";
        uses = "cachix/cachix-action@v17";
        with_ = {
          name = "opinionatedcache";
          authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        };
      };

      # Both caches, for jobs that build and push.
      caches = [
        config.doggate.ci.steps.magicNixCache
        config.doggate.ci.steps.cachix
      ];

      diskUsage = {
        name = "Disk usage";
        if_ = "always()";
        shell = "bash";
        run = ''
          df -h / /nix /mnt || true
          du -sh /tmp build-results 2>/dev/null || true
        '';
      };
    };
  };
}
