{ config, pkgs, ... }: {
  imports = [
    ./browsers.nix
    ./common.nix
    ./git.nix
    ./fusuma.nix
  ];
}

