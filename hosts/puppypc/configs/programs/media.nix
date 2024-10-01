 
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    davinci-resolve
    tenacity
    obs-cmd
  ];
  programs.obs-studio = {
    enable = true;
    plugins = [
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
      pkgs.obs-studio-plugins.obs-websocket
    ];
  };
}
