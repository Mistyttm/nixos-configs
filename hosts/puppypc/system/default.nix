{ config, lib, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./programs.nix
    ./bootloader/bootloader.nix
    ./DE/default.nix
    ./hardware/amd.nix
    ./hardware/nvidia.nix
  ];
}
