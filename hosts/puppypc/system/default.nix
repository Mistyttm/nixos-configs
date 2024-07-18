{ config, lib, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hardware/amd.nix
    ./hardware/nvidia.nix
  ];
}
