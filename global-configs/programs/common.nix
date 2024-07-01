{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
    nodejs
#     discord
    slack
    zoom-us
    obsidian
    spotify
    spicetify-cli
    vlc
    thunderbird
#     betterbird
    libreoffice
    xdg-utils
    pass
    tree
    p7zip
    gnome.zenity
    kdeconnect
    zip
    kup
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
