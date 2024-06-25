{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
    nodejs_18
#     discord
    slack
    zoom-us
    obsidian
    spotify
    spicetify-cli
    vlc
    thunderbird
    libreoffice
    xdg-utils
    pass
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
}
