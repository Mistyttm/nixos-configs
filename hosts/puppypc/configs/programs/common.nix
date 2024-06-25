{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
    (pkgs.discord.override {
      # remove any overrides that you don't want
      withOpenASAR = true;
      withVencord = true;
    })
  ];
  programs.chromium = {
    enable = true;
  };
}
