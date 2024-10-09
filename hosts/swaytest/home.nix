{ pkgs, ... }:
{
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ./swaywm/default.nix
    ../../global-configs/shell/default.nix
  ];

  home.packages = with pkgs; [
    fastfetch
    git
    nwg-dock
  ];

  home.stateVersion = "24.11";

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#swaytest";
    upgrade = "/home/misty/nixos-configs-main && nix flake upgrade && sudo nixos-rebuild switch --flake .#swaytest";
  };

  programs.home-manager.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
