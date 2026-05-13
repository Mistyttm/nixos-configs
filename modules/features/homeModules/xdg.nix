{ inputs, ... }:
{
  flake.homeModules.xdg =
    { pkgs, lib, ... }:
    {
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
        };
        mime.enable = true;
        mimeApps = {
          enable = true;
        };
      };
    };
}
