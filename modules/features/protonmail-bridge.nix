{lib, ...}: {
  flake.homeModules.protonmail = {
    config,
    pkgs,
    ...
  }: {
    services.protonmail-bridge = {
      enable = true;
      package = pkgs.protonmail-bridge-gui;
      logLevel = "info";
    };

    systemd.user.services.protonmail-bridge.Service = {
      After = lib.mkForce ["graphical-session.target"];
      PartOf = lib.mkForce ["graphical-session.target"];
      ExecStart = lib.mkForce "${lib.getExe config.services.protonmail-bridge.package} --log-level ${config.services.protonmail-bridge.logLevel}";
    };
  };
}
