{ pkgs, ... }:
{
  services.prowlarr = {
    enable = true;
    package = pkgs.prowlarr;
    openFirewall = true;
    dataDir = "/var/lib/prowlarr";
    settings = {
      update = {
        automatically = true;
      };
    };
  };
}
