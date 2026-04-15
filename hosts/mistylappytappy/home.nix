{ ... }:
{
  imports = [
    ../../global-configs/home-base.nix
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ../../global-configs/users/emailAccounts.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#mistylappytappy";
    upgrade = "/home/misty/Documents/nixos-configs && nix flake upgrade && sudo nixos-rebuild switch --flake .#mistylappytappy";
  };

  # Avoid activation failures when a previous mimeapps.list.backup already exists.
  xdg.configFile."mimeapps.list".force = true;
}
