{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    vesktop
  ];
  programs.chromium = {
    enable = true;
  };
}

