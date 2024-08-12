{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
    protontricks
    ffmpeg
    piper
    gimp
    wine
#     wineWowPackages.fonts
#     wineWowPackages.waylandFull
#     wineWowPackages.staging
    winetricks
    blockbench
    file
    p7zip
    okteta
  ];
}
