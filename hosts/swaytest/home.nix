{ pkgs, ... }:
{
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ./sway.nix
  ];

  home.packages = with pkgs; [
    fastfetch
    git
  ];

  home.stateVersion = "24.11";

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#mistylappytappy";
    upgrade = "/home/misty/Documents/nixos-configs && nix flake upgrade && sudo nixos-rebuild switch --flake .#mistylappytappy";
  };

  programs.home-manager.enable = true;
}
