{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
    nodejs_18
    discord
    slack
    zoom-us
    obsidian
    spotify
    spicetify-cli
    vlc
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
}
