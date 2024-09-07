{lib, config, ...}:

{
  options = {
    custom = {
      services = {
        enable = lib.mkEnableOption "Enable services";
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
        enable = lib.mkif config.custom.services.ratbagd.enable true;
      };
      gnome.gnome-keyring = {
        enable = lib.mkif config.custom.services.gnome.gnome-keyring.enable true;
      };
      earlyoom = {
        enable = lib.mkif config.custom.services.earlyoom.enable true;
      };
      pcscd = {
        enable = lib.mkif config.custom.services.pcscd.enable true;
      };
      resolved = {
        enable = lib.mkif config.custom.services.resolvd.enable true;
      };
      touchegg = {
        enable = lib.mkif config.custom.services.touchegg.enable true;
      };
    };
    programs.noisetorch = {
      enable = lib.mkif config.custom.services.noisetorch.enable true;
    };
  };
}