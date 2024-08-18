{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    xdg-utils
    pass
    tree
    nano
    wget
    p7zip
    zip
    tmux
    unzip
  ];
}
