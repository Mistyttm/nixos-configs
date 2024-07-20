{ config, lib, pkgs, ... }: {
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
    };

    pcscd = {
      enable = true;
    };

    resolved = {
      enable = true;
    };

    mullvad-vpn = {
      enable = true;
    };
  };
}
