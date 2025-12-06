{ pkgs, ... }:
{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
