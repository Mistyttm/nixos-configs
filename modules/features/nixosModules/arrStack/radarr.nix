{ self, inputs, ... }:
{
  flake.nixosModules.radarr =
    { pkgs, lib, ... }:
    {
      services.radarr = {
        enable = true;
        package = pkgs.radarr;
        openFirewall = true;
        user = "radarr";
        group = "media";
        dataDir = "/var/lib/radarr";
        settings = {
          update = {
            automatically = true;
          };
          port = 7878;
        };
      };
      users.users.radarr.extraGroups = [ "media" ];
    };
}
