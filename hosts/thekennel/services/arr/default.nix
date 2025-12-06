{ pkgs, ... }:
{
  imports = [
    ./radarr.nix
    ./sonarr.nix
    ./mullvad.nix
  ];
}
