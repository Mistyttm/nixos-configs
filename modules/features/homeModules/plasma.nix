{...}: {
  flake.homeModules.plasma = {
    pkgs,
    lib,
    ...
  }: {
    xdg.configFile."plasma-notification-mirror/config.ini".text = lib.generators.toINI {} {
      General = {
        mode = "secondary";
        screens = "";
        lifetime_ms = 5000;
        width = 332;
        max_notifications = 5;
        right_margin = 18;
        bottom_margin = 508;
        gap = 12;
      };
    };

    systemd.user.services.plasma-notification-mirror = {
      Unit = {
        Description = "Mirror Plasma notification popups to additional monitors";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        StartLimitBurst = 3;
        StartLimitIntervalSec = 60;
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.plasma-notification-mirror}/bin/plasma-notification-mirror";
        WorkingDirectory = "%h";
        Restart = "on-failure";
        RestartSec = "2s";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
