{ inputs, ... }:
{
  flake.nixosModules.mullvad =
    { pkgs, lib, ... }:
    {
      services.mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };
    };
}
