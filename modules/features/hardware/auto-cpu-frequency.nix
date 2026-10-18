{inputs, ...}: {
  flake-file.inputs.auto-cpufreq = {
    url = "git+https://github.com/AdnanHodzic/auto-cpufreq";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.nixosModules.auto-cpu-frequency = {...}: {
    imports = [
      inputs.auto-cpufreq.nixosModules.default
    ];
    programs.auto-cpufreq = {
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
