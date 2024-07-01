{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    zed-editor
    pkg-config
    openssl
    nodePackages.pnpm
  ];
}

