{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
    nodejs_18
    discord
    slack
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
}
