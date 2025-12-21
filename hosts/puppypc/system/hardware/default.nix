{
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./amd.nix
    ./nvidia.nix
    ./hardware-configuration.nix
  ];
}
