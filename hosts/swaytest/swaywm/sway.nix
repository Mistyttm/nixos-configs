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
        {command = "kitty fastfetch";}
        {command = "nwg-dock";}
      ];
      bars = [{
        command = "\${pkgs.waybar}/bin/waybar";
        position = "top";
      }];
    };
  };
} 