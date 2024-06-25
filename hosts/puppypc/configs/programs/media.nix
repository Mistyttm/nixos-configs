 
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    davinci-resolve
    tenacity
  ];
  programs.obs-studio = {
    enable = true;
  };
}
