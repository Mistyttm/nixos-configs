{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    vesktop
    cinny-desktop
    #     ungoogled-chromium
  ];
}
