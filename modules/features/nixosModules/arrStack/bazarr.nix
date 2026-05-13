{ self, inputs, ... }:
{
  flake.nixosModules.bazarr =
    { pkgs, lib, ... }:
    {
      services.bazarr = {
        enable = true;
        openFirewall = true;
        group = "bazarr";
        user = "bazarr";
      };
      users.users.bazarr.extraGroups = [ "media" ];
    };
}
