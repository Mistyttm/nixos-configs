{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    dolphin-emu-beta
    lutris
    BeatSaberModManager
  ];
}

