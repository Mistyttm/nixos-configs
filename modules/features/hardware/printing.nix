{...}: {
  flake.nixosModules.printing = {
    pkgs,
    lib,
    ...
  }: {
    hardware.sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
      disabledDefaultBackends = ["escl"];
    };
    services.printing = {
      enable = true;
      drivers = [
        pkgs.brlaser
        pkgs.brgenml1lpr
        pkgs.brgenml1cupswrapper
      ];
    };
    services.udev.packages = lib.mkIf true [pkgs.sane-airscan];
  };
}
