{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nvidia-docker
  ];

  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker;
      logDriver = "journald";
      liveRestore = true;

      # Enable automatic pruning of old images/containers
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };

      # Configure NVIDIA runtime for GPU access in containers
      daemon.settings = {
        runtimes = {
          nvidia = {
            path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
          };
        };

        # Enable CDI for GPU access
        features = {
          cdi = true;
        };

        # Configure CDI spec directories
        cdi-spec-dirs = [
          "/var/run/cdi"
          "/etc/cdi"
        ];
      };
    };
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
  };
}
