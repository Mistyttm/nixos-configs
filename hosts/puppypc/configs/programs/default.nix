{ config, pkgs, ... }: {
  imports = [
    ./browsers.nix
    ./common.nix
    ./media.nix
    ./development.nix
    ./games.nix
    ./git.nix
  ];
}

