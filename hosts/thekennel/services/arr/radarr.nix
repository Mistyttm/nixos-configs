{ pkgs, ... }:
{
  services.radarr = {
    enable = true;
    package = pkgs.radarr;
    openFirewall = true;
    user = "radarr";
    group = "radarr";
    dataDir = "/var/lib/radarr";
    settings = {
      update = {
        automatically = true;
      };
    };
  };
}
