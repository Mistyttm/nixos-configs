{ pkgs, ... }:
{
  imports = [
    ../../global-configs/home-base.nix
    ../../global-configs/programs/git.nix
    ../../global-configs/programs/xdg.nix
    ../../global-configs/programs/cli.nix
    ../../global-configs/programs/fastfetch.nix
    ./configs/shell.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    nodejs
    direnv
    nil
    packwiz
  ];

  programs.java.enable = true;
}
