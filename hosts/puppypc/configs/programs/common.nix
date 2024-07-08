{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
#     discord
    vencord
    (pkgs.discord.override {
      # remove any overrides that you don't want
      withOpenASAR = true;
      withVencord = true;
    })
    protontricks
    ffmpeg
    piper
  ];
}
