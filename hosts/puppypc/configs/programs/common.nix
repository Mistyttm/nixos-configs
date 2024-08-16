{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
    protontricks
    ffmpeg
    piper
    gimp
    blockbench
    file
  ];
}
