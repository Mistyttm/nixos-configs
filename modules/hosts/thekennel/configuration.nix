{ self, ... }:
{

  flake.nixosModules.thekennelConfiguration =
    { pkgs, ... }:
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
        homepage
        fail2ban
      ];

      networking.hostName = "thekennel";

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

      doggate = {
        nginx = {
          enable = true;
        };
        wireguard = {
          enable = true;
        };
      };

      nixpkgs.config.cudaSupport = true;

      environment.systemPackages = with pkgs; [
        direnv
        nil
      ];

      environment.shellAliases = {
        rebuild = "NH_SHOW_ACTIVATION_LOGS=1 nh os switch . -H puppypc";
      };

      environment.sessionVariables = {
        MOZ_DISABLE_RDD_SANDBOX = "1";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      fileSystems."/mnt/media" = {
        device = "//192.168.0.170/Public/Media";
        fsType = "cifs";
        options = [
          "credentials=/run/secrets/rendered/qnap-media-cifs"
          "rw"
          "vers=3.1.1"
          "_netdev"
          "iocharset=utf8"
          "serverino"
          "gid=986"
          "file_mode=0664"
          "dir_mode=0775"
          "x-systemd.automount"
          "x-systemd.after=network-online.target"
          "x-systemd.requires=network-online.target"
          "x-systemd.requires=sops-nix.service"
          "x-systemd.mount-timeout=30s"
          "nofail"
        ];
      };

      programs.java.enable = true;

      system.stateVersion = "24.05";
    };

}
