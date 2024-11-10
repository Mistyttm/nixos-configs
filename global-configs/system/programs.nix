{ config, lib, pkgs, ... }: {
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    qemu
    sddm-sugar-dark
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraPackages = with pkgs; [
      mono
      mono4
      mono5
    ];
#     gameScopeSession = {
#       enable = true;
#     };
#     extraCompatPackages = with pkgs; [
#       proton-ge-bin
#     ];
  };

  programs.gamemode = {
    enable = true;
  };

  programs.zsh.enable = true;
  users.users.misty.shell = pkgs.zsh;
}
