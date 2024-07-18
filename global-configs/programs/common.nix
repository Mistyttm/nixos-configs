{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
#     discord
    slack
    zoom-us
    obsidian
    spotify
    spicetify-cli
    vlc
    thunderbird
    betterbird
    libreoffice
    xdg-utils
    pass
    tree
    p7zip
    gnome.zenity
    kdeconnect
    zip
    kup
    kdePackages.kalk
    wget
    libnotify
    teams-for-linux
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
