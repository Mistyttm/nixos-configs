{ ... }:
{
  zramSwap = {
    enable = true;
    memoryPercent = 32;
    algorithm = "zstd";
  };
}
