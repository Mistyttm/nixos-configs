{ config, lib, pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
}
