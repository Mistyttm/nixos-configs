{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    mullvad-vpn
    qbittorrent
    protontricks
    (ffmpeg.override { withCuda = true; })
    piper
    gimp
    blockbench
    file
    nil
    nixfmt
    wineWow64Packages.waylandFull
    winetricks
    bottles
    protontricks
    scrcpy
    bs-manager
    vpm
    vrc-get
    satisfactorymodmanager
    plasma-panel-colorizer
    r2modman
    deadlock-mod-manager
    jackify
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

  # Fix: Add startup delay to linux-wallpaperengine service
  # The service starts before KWin has fully initialized displays,
  # causing the wallpaper to render at 16x16 pixels initially
  systemd.user.services.linux-wallpaperengine = {
    Unit = {
      # Wait for plasma-kwin_wayland to be ready
      After = [
        "graphical-session.target"
        "plasma-kwin_wayland.service"
      ];
    };
    Service = {
      # Add a delay to ensure displays are fully enumerated
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      # Restart on failure to recover from race conditions
      Restart = "on-failure";
      RestartSec = "3s";
    };
  };
}
