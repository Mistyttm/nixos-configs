{...}: {
  flake.nixosModules.auto-cpu-frequency = {...}: {
    services.auto-cpufreq = {
      enable = false;
      settings = {
        charger = {
          governor = "performance";
          turbo = "auto";
        };

        battery = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };
  };
}
