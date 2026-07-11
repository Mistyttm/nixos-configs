{...}: {
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
