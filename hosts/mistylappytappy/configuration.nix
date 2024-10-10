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

  system.stateVersion = "unstable";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
