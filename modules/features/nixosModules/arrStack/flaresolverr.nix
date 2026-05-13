{ self, inputs, ... }:
{
  flake.nixosModules.flaresolverr =
    { pkgs, lib, ... }:
    {
      services.flaresolverr = {
        enable = true;
        openFirewall = true;
      };
    };
}
