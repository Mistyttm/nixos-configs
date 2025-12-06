{ pkgs, ... }:
{
  services.sonarr = {
    enable = true;
    package = pkgs.sonarr;
    openFirewall = true;
    user = "sonarr";
    group = "sonarr";
    dataDir = "/var/lib/sonarr";
    settings = {
      update = {
        automatically = true;
      };
    };
  };
}
