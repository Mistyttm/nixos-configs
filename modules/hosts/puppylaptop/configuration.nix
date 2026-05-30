{ self, ... }:
{
  flake.nixosModules.puppylaptopConfiguration =
    { pkgs, ... }:
    {
      # import any other modules from here
      imports = with self.nixosModules; [
        puppylaptopHardware
        puppylaptopHomeManager
        audio
        plymouth
        system-essentials
        auto-cpu-frequency
        misty
        bluetooth
        docker
        firefox
        sddm
        plasma
        printing
        prismlauncher
        steam
        fonts
        cli-tools
        nix-ld
        nvidia
        mullvad
      ];

      networking.hostName = "puppylaptop";

      boot = {
        kernelPackages = pkgs.linuxPackages_zen;
        supportedFilesystems = [ "ntfs" ];
        kernelModules = [ "ntsync" ];
      };

      hardware.nvidia-custom = {
        enable = true;
        driverChannel = "latest";
        prime = {
          enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      doggate.wireguard = {
        enable = true;
      };

      nixpkgs.config.cudaSupport = true;

      environment.systemPackages = with pkgs; [
        touchegg
        texliveFull
      ];

      environment.sessionVariables = {
        MOZ_DISABLE_RDD_SANDBOX = "1";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      programs.nh.flake = "/home/misty/.config/.nixos";

      system.stateVersion = "25.05";
    };
}
