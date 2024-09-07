{ lib, config, ...}:
{
    options = {
      custom = {
        services = {
          enable = lib.mkEnableOption "Enable services";
          description = ''
            Enable services like ratbagd, gnome-keyring, earlyoom, pcscd, resolved, mullvad-vpn, touchegg.'';
          ratbagd = {
            enable = lib.mkEnableOption "Enable ratbagd";
            default = true;
          };
          gnome = {
            gnome-keyring = {
              enable = lib.mkEnableOption "Enable gnome-keyring";
              default = true;
            };
          };
          earlyoom = {
            enable = lib.mkEnableOption "Enable earlyoom";
            default = true;
          };
          pcscd = {
            enable = lib.mkEnableOption "Enable pcscd";
            default = true;
          };
          resolved = {
            enable = lib.mkEnableOption "Enable resolved";
            default = true;
          };
          mullvad-vpn = {
            enable = lib.mkEnableOption "Enable mullvad-vpn";
            default = true;
          };
          touchegg = {
            enable = lib.mkEnableOption "Enable touchegg";
            default = true;
          };
          noisetorch = {
            enable = lib.mkEnableOption "Enable noisetorch";
            default = true;
          };
        };
      };
    };

    config = lib.mkIf config.custom.services.enable {
      services = {
        ratbagd = {
          enable = if config.custom.services.ratbagd.enable then true else false;
        };
    
        gnome.gnome-keyring = {
          enable = if config.custom.services.gnome.gnome-keyring.enable then true else false;
        };

        earlyoom = {
          enable = if config.custom.services.earlyoom.enable then true else false;
        };

        pcscd = {
          enable = if config.custom.services.pcscd.enable then true else false;
        };

        resolved = {
          enable = if config.custom.services.resolved.enable then true else false;
        };

        touchegg = {
          enable = if config.custom.services.touchegg.enable then true else false;
        };
    };
    programs.noisetorch = {
      enable = if config.custom.services.noisetorch.enable then true else false;
    };
  };
}