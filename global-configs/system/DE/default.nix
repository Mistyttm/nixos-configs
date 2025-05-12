{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./audio.nix
    ./SDDM/displaymanager.nix
    ./kde.nix
    ./printing.nix
  ];
}
