{inputs, ...}: {
  flake.nixosModules.laminix = {...}: {
    imports = [
      inputs.omniflake.flakes.laminix.nixosModules.default
    ];

    environment.laminix = {
      enable = true;
      plasma = "full";
      packages = [
        # KDE extras outside the Plasma set
        "kdePackages.kdeconnect-kde"
        "kdePackages.filelight"
        "kdePackages.kalk"

        # environment.systemPackages
        "dolphin-emu"
        "piper"
        "prismlauncher"
        "proton-vpn"
        "protonplus"

        # home.packages
        "gimp"
        "qbittorrent"
        "satisfactorymodmanager"
        "vlc"
        "zenity"
      ];
    };
  };
}
