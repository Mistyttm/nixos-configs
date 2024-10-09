{ pkgs, ... }: {
  programs.waybar = {
    enable = true;
    packagee = pkgs.waybar;
    systemd = {
      enable = true;
    };
  };
}