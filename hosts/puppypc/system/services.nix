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

    pcscd = {
      enable = true;
    };
  };
}
