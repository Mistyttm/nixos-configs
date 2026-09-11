{...}: {
  flake.nixosModules.cli-tools = {
    config,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      xdg-utils
      pass
      tree
      nano
      wget
      p7zip
      zip
      tmux
      unzip
      age
      sops
      ookla-speedtest
      rar
      cabextract
      nixfmt
      nixd
      nil
      scrcpy
      file
      nixfmt
      rsync
      strace

      (pkgs.writeShellApplication {
        name = "rebuild";
        runtimeInputs = [config.programs.nh.package pkgs.fwupd];
        text = ''
          echo "==> Checking firmware updates..."
          fwupdmgr refresh --force || true
          fwupdmgr get-updates && fwupdmgr update -y --no-reboot-check || true

          echo "==> Rebuilding NixOS..."
          if [ -z "''${NH_FLAKE:-}" ]; then
            echo "rebuild: NH_FLAKE is not set (configure programs.nh.flake for ${config.networking.hostName})"
            exit 1
          fi
          exec env NH_SHOW_ACTIVATION_LOGS=1 nh os switch -H "${config.networking.hostName}" "$@"
        '';
      })
    ];
  };
}
