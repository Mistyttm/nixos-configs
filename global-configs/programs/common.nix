{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
    (unstable.pkgs.discord.override {
      # remove any overrides that you don't want
      withOpenASAR = true;
      withVencord = true;
    })
    slack
    unstable.zoom-us
    obsidian
    spicetify-cli
    vlc
    thunderbird
    libreoffice
    gnome.zenity
    kdeconnect
    kdePackages.kalk
    libnotify
    teams-for-linux
    cabextract
    rpi-imager
    quickemu
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  programs.direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
}
