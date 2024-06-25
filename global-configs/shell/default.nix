{ config, pkgs, ... }: {
  imports = [
    ./oh-my-posh.nix
    ./terminals.nix
    ./zsh.nix
  ];
}
