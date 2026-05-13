{ inputs, ... }:
{
  flake.homeModules.kdeconnect =
    { pkgs, lib, ... }:
    {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
}
