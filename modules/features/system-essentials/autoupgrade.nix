{self, ...}: {
  flake.nixosModules.auto-upgrade = {...}: {
    system.autoUpgrade = {
      enable = true;
      flake = "github:Mistyttm/nixos-configs/main";
      upgrade = false;
      flags = [
        "--print-build-logs"
      ];
      dates = "02:00";
      randomizedDelaySec = "45min";
      runGarbageCollection = true;
    };
  };

  flake.nixosModules.auto-upgrade-reboot = {...}: {
    imports = [self.nixosModules.auto-upgrade];

    system.autoUpgrade = {
      allowReboot = true;
      # Checked once the build finishes, so leave room for local builds after `dates`.
      rebootWindow = {
        lower = "01:55";
        upper = "06:00";
      };
    };
  };
}
