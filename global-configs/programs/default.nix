{ config, pkgs, ... }: {
  imports = [
    ./browsers.nix
    ./chat.nix
    ./common.nix
    ./fastfetch.nix
    ./games/default.nix
    ./git.nix
    ./media.nix
    ./productivity.nix
    ./spotify.nix
    ./vscode.nix
    ./xdg.nix
  ];
}
