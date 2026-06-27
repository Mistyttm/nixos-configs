{self, ...}: {
  flake.nixosModules.thekennelConfiguration = {
    config,
    pkgs,
    ...
  }: {
    # import any other modules from here
    imports = with self.nixosModules; [
      thekennelHardware
      thekennelHomeManager
      system-essentials
      misty
      docker
      fonts
      cli-tools
      nix-ld
      nvidia
      mullvad
      jellyfin
      homepage
      fail2ban
      arrStack
      downloaders
      prometheus-server
    ];

    networking.hostName = "thekennel";

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
    };

    hardware.nvidia-custom = {
      enable = true;
      driverChannel = "bleeding_edge";
      blacklistNova = true;
      nvidiaContainerToolkit = true;
    };

    doggate = {
      nginx = {
        enable = true;
      };
      wireguard = {
        enable = true;
      };
    };

    monitoring.scrapeTargets = [
      {
        job_name = "thedogpark";
        static_configs = [
          {
            targets = [
              "10.100.0.1:9100" # node
              "10.100.0.1:9113" # nginx
              "10.100.0.1:9586" # wireguard
              "10.100.0.1:9148" # synapse
            ];
            labels = {host = "thedogpark";};
          }
        ];
      }
    ];

    nixpkgs.config.cudaSupport = true;

    environment.systemPackages = with pkgs; [
      direnv
      nil
      intel-vaapi-driver
      btop # Resource monitor
      ncdu # Disk usage analyzer
      mediainfo # Media file inspector
      mkvtoolnix # MKV manipulation tools
      bc
    ];

    environment.shellAliases = {
      rebuild = "NH_SHOW_ACTIVATION_LOGS=1 nh os switch . -H puppypc";
    };

    programs.nh.flake = "/home/misty/.nixos";

    environment.sessionVariables = {
      MOZ_DISABLE_RDD_SANDBOX = "1";
      LIBVA_DRIVER_NAME = "nvidia";
    };

    sops.secrets."qnap-media/username" = {
      sopsFile = self.secrets.qnap;
    };

    sops.secrets."qnap-media/password" = {
      sopsFile = self.secrets.qnap;
    };

    sops.templates.qnap-media-cifs = {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        username=${config.sops.placeholder."qnap-media/username"}
        password=${config.sops.placeholder."qnap-media/password"}
      '';
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

    programs.mtr.enable = true;

    system.stateVersion = "24.05";
  };
}
