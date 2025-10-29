{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
    protontricks
    ffmpeg
    piper
    gimp
    blockbench
    file
    nil
    nixfmt-rfc-style
    wineWowPackages.waylandFull
    winetricks
    bottles
    protontricks
    scrcpy
    bs-manager
    vpm
    vrc-get
    satis.satisfactorymodmanager
    plasma-panel-colorizer
    r2modman
  ];

  services.linux-wallpaperengine = {
    enable = true;
    assetsPath = "${config.xdg.dataHome}/Steam/steamapps/common/wallpaper_engine/assets";
    wallpapers = [
      {
        monitor = "DP-5";
        wallpaperId = "3328281976";
      }
      {
        monitor = "DP-4";
        wallpaperId = "3215623224";
        extraOptions = [ "--silent" ];
      }
    ];
  };
}
