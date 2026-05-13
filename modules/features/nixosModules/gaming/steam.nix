{ inputs, ... }:
{
  flake.nixosModules.steam =
    { pkgs, lib, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraPackages = with pkgs; [
          gamescope
          mangohud
        ];
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
        package = pkgs.steam.override {
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
