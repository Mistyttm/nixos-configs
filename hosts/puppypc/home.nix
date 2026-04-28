{ ... }:
{
  imports = [
    ../../global-configs/home-base.nix
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    upgrade = "/home/misty/Documents/nixos-configs-main && nix flake update && sudo nixos-rebuild switch --flake .#puppypc";
  };

  # Avoid activation failures when a previous mimeapps.list.backup already exists.
  xdg.configFile."mimeapps.list".force = true;
}
