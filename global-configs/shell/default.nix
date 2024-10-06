{ config, pkgs, ... }: {
  imports = [
    ./environment.nix
    ./oh-my-posh.nix
    ./terminals.nix
    ./zsh.nix
  ];
}
