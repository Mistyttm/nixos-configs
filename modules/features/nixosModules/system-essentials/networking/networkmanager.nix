{ inputs, ... }:
{
  flake.nixosModules.networkmanager =
    { pkgs, lib, ... }:
    {
      networking.networkmanager.enable = true;
    };
}
