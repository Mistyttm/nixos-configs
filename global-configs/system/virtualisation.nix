{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker;
      logDriver = "journald";
      liveRestore = true;
    };
    libvirtd = {
      enable = true;
    };
  };
}
