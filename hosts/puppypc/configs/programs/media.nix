 
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    davinci-resolve
    tenacity
  ];
  programs.obs-studio = {
    enable = true;
    plugins = [
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
    ];
  };
}
