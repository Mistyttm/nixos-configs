{ config, pkgs, ... }: {
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      startup = [
        {command = "fastfetch";}
      ];
    };
  };
}