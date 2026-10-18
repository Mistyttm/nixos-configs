{inputs, ...}: {
  flake-file.inputs.skwd-wall.url = "github:liixini/skwd-wall";

  flake.nixosModules.skwd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    skwd = inputs.skwd-wall;
    skwd-wall = skwd.packages.${pkgs.stdenv.hostPlatform.system}.default;
    skwd-paper-plasma = skwd.packages.${pkgs.stdenv.hostPlatform.system}.skwd-paper-plasma;
    # skwd-walld only looks for qdbus6/qdbus-qt6, but nixpkgs' Qt6 qttools ships it as plain qdbus.
    qdbus6 = pkgs.writeShellScriptBin "qdbus6" ''
      exec ${pkgs.kdePackages.qttools}/bin/qdbus "$@"
    '';
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

    # Tools skwd-walld spawns by name that aren't in a user service's default PATH:
    # dbus-monitor for the Plasma Activity watcher, setsid + sh for detached hooks.
    systemd.user.services.skwd-walld.path = [
      qdbus6
      pkgs.dbus
      pkgs.util-linux
      pkgs.bash
    ];
  };
}
