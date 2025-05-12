{ pkgs, ... }:
{
  services.sonarr = {
    enable = true;
    package = pkgs.radarr;
    openFirewall = true;
    user = "sonarr";
    group = "sonarr";
    dataDir = "/var/lib/sonarr";
  };
}
