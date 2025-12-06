{ pkgs, ... }:
{
  imports = [
    ./radarr.nix
    ./sonarr.nix
    ./mullvad.nix
    ./prowlarr.nix
    ./qbitorrent.nix
    ./flaresolverr.nix
  ];
}
