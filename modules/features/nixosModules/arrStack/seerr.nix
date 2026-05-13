{ self, inputs, ... }:
{
  flake.nixosModules.seerr =
    { pkgs, lib, ... }:
    {
      services.seerr = {
        enable = true;
        openFirewall = true;
      };
    };
}
