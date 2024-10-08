{ config, pkgs, ... }:
{
  # TODO please change the username & home directory to your own
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
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
  home.stateVersion = "24.05";

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    upgrade = "/home/misty/Documents/nixos-configs-main && nix flake upgrade && sudo nixos-rebuild switch --flake .#puppypc";
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

}
