{ config, pkgs, ... }: {
  programs.discord = {
    enable = true;
  };
  programs.slack = {
    enable = true;
  };
}
