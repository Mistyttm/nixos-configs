{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    dolphin-emu-beta
    lutris
    personal.bs-manager
  ];
}

