{ inputs, ... }:
{
  flake.nixosModules.xdg =
    { pkgs, lib, ... }:
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
      };
    };
}
