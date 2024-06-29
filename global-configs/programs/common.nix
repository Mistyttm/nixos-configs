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
    tree
    p7zip
    gnome.zenity
    kdeconnect
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
