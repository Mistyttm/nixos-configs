{ config, lib, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware/default.nix
    ./systemd.nix
  ];
}
