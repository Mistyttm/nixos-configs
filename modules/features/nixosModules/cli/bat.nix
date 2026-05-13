{ inputs, ... }:
{
  flake.nixosModules.bat =
    { pkgs, lib, ... }:
    {
      programs.bat = {
        enable = true;
      };
    };
}
