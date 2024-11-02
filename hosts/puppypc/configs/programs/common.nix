{ pkgs, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
    protontricks
    ffmpeg
    piper
    gimp
    blockbench
    file
    nil
    nixfmt-rfc-style
    wine-wayland
    winetricks
    protontricks
    fritzing
    scrcpy
  ];
}
