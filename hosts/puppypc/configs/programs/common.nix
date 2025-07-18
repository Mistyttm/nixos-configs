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
    wineWowPackages.waylandFull
    winetricks
    bottles
    protontricks
    scrcpy
    bs-manager
    vpm
    vrc-get
    satisfactorymodmanager
    plasma-panel-colorizer
  ];
}
