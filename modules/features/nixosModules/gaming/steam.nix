{inputs, ...}: {
  flake.nixosModules.steam = {pkgs, ...}: {
    nixpkgs.overlays = [inputs.millennium.overlays.default];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = with pkgs; [
        gamescope
        mangohud
      ];
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        proton-cachyos
        proton-ge-rtsp
      ];
      package = pkgs.millennium-steam.override {
        extraEnv = {
          OBS_VKCAPTURE = true;
        };
      };
    };

    programs.gamemode = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      protonplus
      protontricks
      wineWow64Packages.waylandFull
      winetricks
    ];
  };
}
