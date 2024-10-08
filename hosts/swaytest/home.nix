{ config, pkgs, ... }:
{
  # TODO please change the username & home directory to your own
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ./sway.nix
  ];

  # Packages that should be installed to the user profile.
#  home.packages = with pkgs; [
#
#  ];
  
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#mistylappytappy";
    upgrade = "/home/misty/Documents/nixos-configs && nix flake upgrade && sudo nixos-rebuild switch --flake .#mistylappytappy";
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

}
