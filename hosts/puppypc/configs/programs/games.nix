{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dolphin-emu-beta
    lutris
    #     beatsabermodmanager
  ];
}
