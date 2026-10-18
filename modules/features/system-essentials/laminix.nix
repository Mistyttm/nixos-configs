{inputs, ...}: {
  flake-file.inputs.laminix = {
    url = "github:jackboykin/laminix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.nixosModules.laminix = {...}: {
    imports = [
      inputs.laminix.nixosModules.default
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
