{ lib, pkgs, config, ... }: {
  imports = [
    ./deadlock.nix
    ./satisfactory.nix
  ];
}
