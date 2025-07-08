{ pkgs, ... }:
{
  #   imports = [
  #     pkgs.nixosModules.saneExtraBackends.brscan4
  #     ./hardware-configuration.nix
  #   ];
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    disabledDefaultBackends = [ "escl" ];
    #     brscan4 = {
    #         enable = true;
    #         netDevices = {
    #           home = { model = "MFC-L28800W"; ip = "192.168.20.4"; };
    #         };
    #       };
  };
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

    resolved = {
      enable = true;
    };

    mullvad-vpn = {
      enable = true;
    };

    printing = {
      enable = true;
      drivers = [
        pkgs.brlaser
        pkgs.brgenml1lpr
        pkgs.brgenml1cupswrapper
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    udev.packages = [ pkgs.sane-airscan ];

    lact = {
      enable = true;
      package = pkgs.lact;
    };
  };

  programs.noisetorch.enable = true;
}
