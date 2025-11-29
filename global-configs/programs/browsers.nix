{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    # Using ESR to avoid build reference issues on unstable
    package = pkgs.firefox-esr;
  };
}
