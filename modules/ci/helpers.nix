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
    # Plain nix-store commands ignore flake nixConfig, so set the caches system-wide.
    nixConfig = lib.concatStringsSep "\n" (
      [
        "experimental-features = nix-command flakes"
        "accept-flake-config = true"
      ]
      ++ lib.mapAttrsToList (name: value: "${name} = ${toString value}") (
        # Empty defaults like `substituters = []` would wipe cache.nixos.org.
        lib.filterAttrs (_: value: value != null && value != [] && value != "") config.flake-file.nixConfig
      )
    );

    allCoresNixConfig = [
      "max-jobs = auto"
      "cores = 0"
      "substitute = true"
      "builders ="
    ];

    script = workflow: name: builtins.readFile ./${workflow}/${name}.sh;

    runners = {
      x86_64-linux = "ubuntu-latest";
      aarch64-linux = "ubuntu-24.04-arm";
    };

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

      configureGit = {
        name = "Configure Git";
        run = ''
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
        '';
      };

      # `arch` is a GitHub expression like "matrix.arch"; null for x86_64-only jobs.
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

      cachix = {
        name = "Setup Cachix";
        uses = "cachix/cachix-action@v17";
        with_ = {
          name = "opinionatedcache";
          authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        };
      };

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
