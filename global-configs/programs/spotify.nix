{ config, pkgs, ... }: {
  programs.spotify = {
    enable = true;
  };
  programs.spicetify-cli = {
    enable = true;
  };
}
