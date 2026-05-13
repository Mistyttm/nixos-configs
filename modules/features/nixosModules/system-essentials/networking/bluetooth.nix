{ inputs, ... }:
{
  flake.nixosModules.bluetooth =
    { pkgs, lib, ... }:
    {
      hardware.bluetooth = {
        enable = true; # enables support for Bluetooth
        powerOnBoot = true;
        settings = {
          General = {
            FastConnectable = true;
            ControllerMode = "bredr";
            Experimental = true;
          };
        };
      };

      services.pipewire.wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "hsp_hs"
            "hfp_hf"
          ];
        };
        # Prevent unclean Bluetooth disconnects from crashing WirePlumber and
        # taking down the entire audio stack (bluez transport release failures)
        "wireplumber.profiles" = {
          main = {
            "monitor.bluez.seat-monitoring" = "disabled";
          };
        };
      };
      boot.extraModprobeConfig = ''
        options btusb enable_autosuspend=0
      '';
    };
}
