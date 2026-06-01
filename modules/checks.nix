{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      pre-commit = {
        settings.hooks = {
          deadnix = {
            enable = true;
            package = pkgs.deadnix;
            settings = {
              edit = true;
            };
          };
          commitizen.enable = true;
          alejandra = {
            enable = true;
            package = pkgs.alejandra;
          };
        };
      };
    };
}
