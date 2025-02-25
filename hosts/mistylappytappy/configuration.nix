{ pkgs, ... }:

{
  imports =
    [
      ./system/default.nix
      ../../global-configs/system/default.nix
      ../../global-configs/users/default.nix
      ../../global-configs/fonts/fonts.nix
    ];
  networking.hostName = "mistylappytappy";

  boot.supportedFilesystems = [ "ntfs" ];

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

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
      jdkOverrides = with pkgs; [ jdk8 jdk17 jdk21 ];
    };
    dolphin = false;
    lutris = false;
    gamemode = true;
  };

  system.stateVersion = "unstable";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
