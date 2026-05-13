{ inputs, ... }:
{
  flake.nixosModules.zram =
    { pkgs, lib, ... }:
    {
      zramSwap = {
        enable = true;
        memoryPercent = 32;
        algorithm = "zstd";
      };
    };
}
