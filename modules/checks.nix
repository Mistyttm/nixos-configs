{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      checks.pre-commit-check = (inputs.pre-commit-hooks.lib."${system}").run {
        src = ./.;
        hooks = {
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
          };
          deadnix.enable = true;
          commitizen.enable = true;
        };
      };
    };
}
