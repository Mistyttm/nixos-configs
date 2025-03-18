{ config, pkgs, ... }:
{
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.stateVersion = "25.05";

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    upgrade = "/home/misty/Documents/nixos-configs-main && nix flake update && sudo nixos-rebuild switch --flake .#puppypc";
  };

  programs.home-manager.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
