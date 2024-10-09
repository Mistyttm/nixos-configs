{ pkgs, ... }: {
  wayland.windowManager.sway = {
    enable = true;
    systemd = {
      enable = true;
    };
    package = pkgs.sway;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      startup = [
        {command = "firefox";}
      ];
      bars = [{
        waybar = {
          command = "\${pkgs.waybar}/bin/waybar";
        };
      }];
    };
  };
}