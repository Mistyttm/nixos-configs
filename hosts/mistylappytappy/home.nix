{ homeVersion, ... }:
{
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ../../global-configs/users/emailAccounts.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.stateVersion = homeVersion;

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#mistylappytappy";
    upgrade = "/home/misty/Documents/nixos-configs && nix flake upgrade && sudo nixos-rebuild switch --flake .#mistylappytappy";
  };

  programs.home-manager.enable = true;
}
