{ self, ... }:
{

  flake.nixosModules.puppypcConfiguration =
    { pkgs, ... }:
    {
      # import any other modules from here
      imports = with self.nixosModules; [
        puppypcHardware
        puppypcHomeManager
        system-essentials
        misty
        bluetooth
        docker
        firefox
        lact
        sddm
        plasma
        printing
        prismlauncher
        steam
        wivrn
        fonts
        cli-tools
        nix-ld
        nvidia
        amd-cpu
        obs
        gaming
        mullvad
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

      programs.nh.flake = "/home/misty/Documents/nixos-configs-main";

      environment.sessionVariables = {
        MOZ_DISABLE_RDD_SANDBOX = "1";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      networking.firewall.allowedTCPPorts = [
        5173
      ];
      networking.firewall.allowedUDPPorts = [
        5173
      ];

      system.stateVersion = "24.05";
    };

}
