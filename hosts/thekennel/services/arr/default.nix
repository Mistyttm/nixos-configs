{ pkgs, ... }:
{
  imports = [
    ./radarr.nix
    ./sonarr.nix
  ];
}
