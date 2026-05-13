{ self, inputs, ... }:
{

  flake.nixosModules.thekennelConfiguration =
    { pkgs, lib, ... }:
    {
      # import any other modules from here
      imports = with self.nixosModules; [
        puppypcHardware
        puppypcHomeManager
        system-essentials
        misty
        docker
        fonts
        cli-tools
        bat
        nix-ld
        nvidia
        mullvad
        jellyfin
      ];

      networking.hostName = "puppypc";

      boot = {
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
        supportedFilesystems = [ "ntfs" ];
        kernelModules = [ "ntsync" ];
      };

      hardware.nvidia-custom = {
        enable = true;
        driverChannel = "beta";
        blacklistNova = true;
        extraGraphicsPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };

      doggate.wireguard = {
        enable = true;
      };

      nixpkgs.config.cudaSupport = true;

      environment.systemPackages = with pkgs; [
        piper
        gamescope
        texliveFull
      ];

      environment.shellAliases = {
        rebuild = "NH_SHOW_ACTIVATION_LOGS=1 nh os switch . -H puppypc";
      };

      environment.sessionVariables = {
        MOZ_DISABLE_RDD_SANDBOX = "1";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      system.stateVersion = "24.05";
    };

}
