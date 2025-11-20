{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # davinci-resolve
    # tenacity
    obs-cmd
  ];
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-websocket
      obs-vkcapture
    ];
  };
}
