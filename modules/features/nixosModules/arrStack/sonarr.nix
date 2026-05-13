{ self, inputs, ... }:
{
  flake.nixosModules.sonarr =
    { pkgs, lib, ... }:
    {
      services.radarr = {
        enable = true;
        package = pkgs.sonarr;
        openFirewall = true;
        user = "sonarr";
        group = "media";
        dataDir = "/var/lib/sonarr";
        settings = {
          update = {
            automatically = true;
          };
          port = 8989;
        };
      };
      users.users.sonarr.extraGroups = [ "media" ];
    };
}
