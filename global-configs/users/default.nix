{ config, lib, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./misty.nix
  ];
}

