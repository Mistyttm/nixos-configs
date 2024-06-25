{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libsecret
    nodejs_18
  ];
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
}
