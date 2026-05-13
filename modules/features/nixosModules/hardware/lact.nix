{ inputs, ... }:
{
  flake.nixosModules.lact =
    { pkgs, lib, ... }:
    {
      services.lact = {
        enable = true;
        package = pkgs.lact;
      };
    };
}
