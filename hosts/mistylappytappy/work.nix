{ ... }:
{
  home.username = "wagtailpsychology";
  home.homeDirectory = "/home/wagtailpsychology";

  imports = [
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/browsers.nix
    ../../global-configs/programs/cli.nix
    ../../global-configs/programs/spotify.nix
    ../../global-configs/programs/thunderbird.nix
    ../../global-configs/programs/xdg.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.stateVersion = "24.11";

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#mistylappytappy";
    upgrade = "/home/misty/Documents/nixos-configs && nix flake upgrade && sudo nixos-rebuild switch --flake .#mistylappytappy";
  };

  programs.home-manager.enable = true;
}
