{ config, lib, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./locale.nix
    ./programs.nix
    ./bootloader/bootloader.nix
    ./DE/default.nix
    ./hardware/amd.nix
    ./hardware/nvidia.nix
    ./networking/networkmanager.nix
    ./networking/ssh.nix
  ];
}
