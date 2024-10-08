{ config, pkgs, lib, ... }: {
    home.shellAliases = {
        # NixOS Aliases
        dev = "nix develop";

        # Git Aliases
        g = "git";
        gpull = "git pull";
        gfetch = "git fetch origin --prune";
        gc = "git commit";
        gpush = "git push";
    };
}
