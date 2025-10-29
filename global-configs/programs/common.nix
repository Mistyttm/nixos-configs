{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libsecret
    (pkgs.discord.override {
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
    birdtray
    libreoffice-qt
    zenity
    libnotify
    teams-for-linux
    cabextract
    # rpi-imager
    quickemu
    python3
    nil
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

  services.easyeffects = {
    enable = true;
    package = pkgs.easyeffects;
  };
}
