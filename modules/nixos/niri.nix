{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.desktops.niri;
in
{
  options.desktops.niri = {
    enable = mkEnableOption "Enable Niri desktop environment configuration";
  };

  config = mkIf cfg.enable {
    programs.niri.enable = true;
    services.gnome.gnome-keyring.enable = false;

    environment.systemPackages = with pkgs; [
      mako
      brightnessctl
      xwayland-satellite
      waybar
      fuzzel
      swaylock
      swaybg
      pavucontrol
      clipse
      qt6ct
      darkly
      kdePackages.dolphin
      nautilus
      kwalletcli
      kdePackages.kwallet
      swayidle
      kdePackages.polkit-kde-agent-1
    ];

    xdg.portal.extraPortals = [
      pkgs.kdePackages.kwallet
    ];

    xdg.portal.config = {
      common = {
        default = [
          "gnome"
        ];
      };
    };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "niri.service" ];
        wants = [ "niri.service" ];
        after = [ "niri.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    programs.foot = {
      enable = true;
    };

    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };
  };
}
