{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    dolphin-emu-beta
  ];
  programs.steam = {
    enable = true;
    protontricks = {
      enable = true;
    };
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [
      proton-ge-bin
    ];
  };
}

