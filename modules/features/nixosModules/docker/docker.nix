{...}: {
  flake.nixosModules.docker = {pkgs, ...}: {
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
          flags = ["--all"];
        };
      };
      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };
    };
  };
}
