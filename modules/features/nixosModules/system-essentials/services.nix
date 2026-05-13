{ inputs, ... }:
{
  flake.nixosModules.services =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services = {
        ratbagd = {
          enable = true;
        };

        gnome = {
          gnome-keyring = {
            enable = true;
          };
        };

        earlyoom = {
          enable = true;
          enableNotifications = true;
        };

        pcscd = {
          enable = true;
        };

        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

      };
    };
}
