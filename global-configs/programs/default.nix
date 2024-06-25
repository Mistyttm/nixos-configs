{ config, pkgs, ... }: {
  imports = [
    ./browsers.nix
    ./common.nix
    ./fastfetch.nix
    ./games/default.nix
    ./git.nix
    ./media.nix
    ./productivity.nix
    ./vscode.nix
    ./xdg.nix
  ];
}
