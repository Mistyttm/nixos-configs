{ pkgs, ... }: {
  services.radarr = {
    enable = true;
    package = pkgs.sonarr;
    openFirewall = true;
    user = "sonarr";
    group = "sonarr";
    dataDir = "/var/lib/sonarr";
    configDir = "/var/lib/sonarr/config";
  };
}