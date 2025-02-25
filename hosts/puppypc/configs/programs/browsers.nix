{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    (vesktop.override {
      electron = pkgs.electron_33;
    })
#     ungoogled-chromium
  ];
}

