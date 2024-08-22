{ config, lib, pkgs, ... }: {
  services = {
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

    nginx = {
      enable = true;
    };
  };
}
