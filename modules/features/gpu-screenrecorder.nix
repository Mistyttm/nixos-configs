{...}: {
  flake.nixosModules.gpu-screenrecorder = {pkgs, ...}: {
    programs.gpu-screen-recorder = {
      enable = true;
      ui = {
        enable = true;
      };
    };
  };
}
