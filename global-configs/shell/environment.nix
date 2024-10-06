{ config, pkgs, lib, ... }: {
    home.shellAliases = {
        # NixOS Aliases
        rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
        upgrade = "/home/misty/Documents/nixos-configs-main && nix flake upgrade && sudo nixos-rebuild switch --flake .#puppypc";
        dev = "nix develop";

        # Git Aliases
        g = "git";
        gpull = "git pull";
        gfetch = "git fetch origin --prune";
        gc = "git commit";
        gpush = "git push";
    };
}
