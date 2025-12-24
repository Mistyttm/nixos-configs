{ homeVersion, ... }:
{
  home.username = "misty";
  home.homeDirectory = "/home/misty";
  home.stateVersion = homeVersion;

  programs.home-manager.enable = true;
}
