{ config, pkgs, ... }: {
  programs.thunderbird = {
    enable = true;
    package = pkgs.unstable.betterbird-unwrapped;
  };
}
