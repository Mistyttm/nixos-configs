{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
#     (pkgs.discord.override {
      # remove any overrides that you don't want
#       withOpenASAR = true;
#       withVencord = true;
#     })
    protontricks
    lightly-qt
    touchegg
  ];
}
