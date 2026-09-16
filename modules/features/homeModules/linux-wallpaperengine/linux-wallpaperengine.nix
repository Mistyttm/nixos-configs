{...}: {
  flake.homeModules.linux-wallpaperengine = {
    pkgs,
    config,
    ...
  }: let
    # Name of the playlist as created in the Wallpaper Engine app.
    # Rotation interval and random/sequential order are configured there.
    playlist = ["--playlist" "misty-rotation"];
  in {
    services.linux-wallpaperengine = {
      enable = true;
      package = pkgs.linux-wallpaperengine.overrideAttrs (_final: prev: {
        patches = (prev.patches or []) ++ [./linux-wallpaperengine-playlist-path.patch ./linux-wallpaperengine-albumart-listener-leak.patch];
      });
      assetsPath = "${config.xdg.dataHome}/Steam/steamapps/common/wallpaper_engine/assets";
      wallpapers = [
        {
          monitor = "DP-2";
          wallpaperId = "3328281976";
          extraOptions = playlist;
        }
        {
          monitor = "DP-1";
          wallpaperId = "3215623224";
          extraOptions = playlist;
        }
        {
          monitor = "DP-5";
          wallpaperId = "3328281976";
          extraOptions = playlist ++ ["--silent"];
        }
        {
          monitor = "DP-4";
          wallpaperId = "3215623224";
          extraOptions = playlist;
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
        # Keep failures from turning into session-wide restart storms.
        StartLimitBurst = 3;
        StartLimitIntervalSec = 60;
      };
      Service = {
        # Add a delay to ensure displays are fully enumerated
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
        # Restart on failure to recover from race conditions
        Restart = "on-failure";
        RestartSec = "10s";
        # Keep animated wallpaper from stealing scheduler time from real-time audio.
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
        CPUWeight = 20;
      };
    };
  };
}
