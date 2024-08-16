{ lib, pkgs, config, ...}:
let 
    cfg = config.serviceModules;
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
    options = {
        serviceModules.enable = lib.mkEnableOption "Enable Module";
        packages = mkOption {
            description = "A module allowing the enabling and disabling of various system services.";
            type = (types.listOf types.str);
            default = [ ];
            example = [ "mullvad-vpn" "earlyoom" ];
        };
    };

    config = lib.mkIf cfg.enable {
        # Only enable services that are specified in cfg.packages and are part of availableServices
        assertions = lib.concatMap (serviceName:
            lib.optional (!lib.hasAttr serviceName availableServices)
                (lib.mkAssertion false ''
                    The service "${serviceName}" is not a recognized service. Valid options are: ${lib.concatStringsSep ", " (lib.attrNames availableServices)}.
                '')
        ) cfg.packages;

        # Apply the configuration to enable the selected services
        lib.mkMerge (lib.map (serviceName:
            lib.mkIf (lib.hasAttr serviceName availableServices) {
                ${availableServices.${serviceName}.enable} = true;
            }
        ) cfg.packages)
    };
}