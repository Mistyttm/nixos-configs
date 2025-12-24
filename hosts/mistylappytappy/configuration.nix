{ pkgs, ... }:

{
  imports = [
    ./system/default.nix
    ../../global-configs/system/default.nix
    ../../global-configs/users/misty.nix
    ../../global-configs/users/wagtailpsychology.nix
    ../../global-configs/fonts/fonts.nix
  ];
  networking.hostName = "mistylappytappy";

  boot.supportedFilesystems = [ "ntfs" ];

  gaming = {
    enable = true;
    user = "misty";
    vr.enable = false;
    steam = {
      enable = true;
      portable = true;
    };
    minecraft = {
      enable = true;
      jdkOverrides = with pkgs; [
        jdk8
        jdk17
        jdk21
      ];
    };
    dolphin = false;
    lutris = false;
    gamemode = true;
  };

  system.stateVersion = "25.11";
}
