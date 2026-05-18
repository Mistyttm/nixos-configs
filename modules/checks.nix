{ ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      formatter = pkgs.nixfmt;

      pre-commit = {
        settings.hooks = {
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
