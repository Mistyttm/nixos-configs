{ pkgs, ... }:
{
  services.sonarr = {
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
    };
  };
}
