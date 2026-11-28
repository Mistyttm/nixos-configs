{...}: {
  flake-file.inputs.devshell = {
    url = "github:numtide/devshell";
    group = "tooling";
  };

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devshells.default = {
      packages =
        [
          pkgs.just
          pkgs.nixfmt
          pkgs.deadnix
        ]
        ++ config.pre-commit.settings.enabledPackages;

      env = [
        {
          name = "TACK_NIX_CONF_TOKENS";
          value = "1";
        }
      ];

      devshell.startup.pre-commit = {
        text = config.pre-commit.shellHook;
      };

      commands = [
        {
          help = "Format Nix files";
          name = "fmt";
          command = "nix fmt";
        }
      ];
    };
  };
}
