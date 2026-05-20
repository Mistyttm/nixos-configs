{ ... }:
{
  flake.homeModules.xdg =
    { ... }:
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
        configFile."mimeapps.list".force = true;
      };
    };
}
