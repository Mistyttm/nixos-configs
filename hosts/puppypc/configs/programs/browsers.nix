{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    vesktop
    element-desktop
#     ungoogled-chromium
  ];
}

