{ config, lib, pkgs, ... }: {
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
#     qemu
    sddm-sugar-dark
    kdePackages.plasma-browser-integration
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.kio-gdrive
    kdePackages.kaccounts-integration
    kdePackages.kaccounts-providers
    kdePackages.signond
    kdePackages.accounts-qt
    kdePackages.signon-kwallet-extension
    libaccounts-glib
  ];

  programs.zsh.enable = true;
  users.users.misty.shell = pkgs.zsh;
}
