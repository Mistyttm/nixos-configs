{ config, lib, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./locale.nix
    ./programs.nix
    ./bootloader.nix
    ./nix.nix
    ./DE/default.nix
    ./networking/default.nix
    ./services.nix
    ./virtualisation.nix
  ];
}

