{ pkgs, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
    protontricks
    ffmpeg
    piper
#     gimp
    blockbench
    file
    nil
    nixfmt-rfc-style
    wineWowPackages.waylandFull
    winetricks
    bottles
    protontricks
    fritzing
    scrcpy
    personal.bs-manager
  ];
}
