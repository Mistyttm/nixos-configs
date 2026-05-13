{ inputs, ... }:
{
  flake.homeModules.mangohud =
    { pkgs, lib, ... }:
    {
      programs.mangohud = {
        enable = true;
        settingsPerApplication = {
          deadlock = {
            gpu_stats = true;
            gpu_name = true;
            fps_limit = 360;
            fps_color_change = true;
            ram = true;
            cpu_mhz = true;
            cpu_power = true;
            gpu_power = true;
            cpu_temp = true;
            gpu_temp = true;
            gpu_mem_temp = true;
            toggle_hud = "Shift_R+F12";
            no_display = true;
          };
          satisfactory = {
            gpu_stats = true;
            gpu_name = true;
            fps_limit = 360;
            fps_color_change = true;
            ram = true;
            cpu_mhz = true;
            cpu_power = true;
            gpu_power = true;
            cpu_temp = true;
            gpu_temp = true;
            gpu_mem_temp = true;
            toggle_hud = "Shift_R+F12";
            no_display = true;
          };
        };
      };
    };
}
