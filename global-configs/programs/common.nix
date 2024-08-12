{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
    (unstable.pkgs.discord.override {
      # remove any overrides that you don't want
      withOpenASAR = true;
      withVencord = true;
    })
    slack
    zoom-us
    obsidian
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
    zip
    kdePackages.kalk
    wget
    libnotify
    teams-for-linux
    cabextract
    rpi-imager
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
