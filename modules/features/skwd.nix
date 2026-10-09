{inputs, ...}: {
  flake.nixosModules.skwd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    skwd = inputs.omniflake.flakes.skwd-wall;
    skwd-wall = skwd.packages.${pkgs.stdenv.hostPlatform.system}.default;
    skwd-paper-plasma = skwd.packages.${pkgs.stdenv.hostPlatform.system}.skwd-paper-plasma;
  in {
    imports = [
      skwd.nixosModules.default
    ];

    environment.systemPackages =
      [
        skwd-wall
      ]
      ++ lib.optionals config.services.desktopManager.plasma6.enable [
        skwd-paper-plasma
      ];

    services.skwd-deck = {
      enable = true;
      extraPackages = lib.optionals config.services.desktopManager.plasma6.enable [
        skwd-paper-plasma
      ];
    };
  };
}
