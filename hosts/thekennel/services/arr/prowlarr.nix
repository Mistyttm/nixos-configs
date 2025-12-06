{ pkgs, ... }:
{
  services.prowlarr = {
    enable = true;
    package = pkgs.prowlarr;
    openFirewall = true;
    user = "prowlarr";
    group = "prowlarr";
    dataDir = "/var/lib/prowlarr";
    settings = {
      update = {
        automatically = true;
      };
    };
  };
}
