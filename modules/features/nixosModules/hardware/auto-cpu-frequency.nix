{ inputs, ... }:
{
  flake.nixosModules.auto-cpu-frequency =
    { ... }:
    {
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
