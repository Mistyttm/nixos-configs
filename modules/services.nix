{ lib, pkgs, config, ...}:
with lib;
let 
    cfg = config.services.serviceModules;
    availableServices = {
        "gnome.gnome-keyring" = config.services.gnome.gnome-keyring.enable;
        "earlyoom" = config.services.earlyoom.enable;
        "pcscd" = config.services.pcscd.enable;
        "ratbagd" = config.services.ratbagd.enable;
        "resolved" = config.services.resolved.enable;
        "mullvad-vpn" = config.services.mullvad-vpn.enable;
        "touchegg" = config.services.touchegg.enable;
    }; 
in {
    options.services = {
        serviceModules.enable = mkEnableOption "Enable Module";
        serviceModules.packages = mkOption {
            description = "A module allowing the enabling and disabling of various system services.";
            type = types.listOf types.str;
            default = [ ];
            example = [ "mullvad-vpn" "earlyoom" ];
        };
    };

    config = mkIf cfg.enable {
        lists.forEach ${cfg.packages} = (serviceName:
            mkIf ()
        )
    };
}