{
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware/default.nix
    ./wireguard.nix
  ];
}
