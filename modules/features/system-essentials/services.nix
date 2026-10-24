{...}: {
  flake.nixosModules.services = {...}: {
    services = {
      ratbagd = {
        enable = true;
      };

      gnome = {
        gnome-keyring = {
          enable = true;
        };
      };

      earlyoom = {
        enable = true;
        enableNotifications = true;
        # Act before zram is completely full and the desktop starts thrashing
        freeSwapThreshold = 20;
        extraArgs = [
          # Kill browser tabs / editor helpers first, never the compositor or shell
          "--prefer"
          "^(Isolated Web Co|Web Content|WebExtensions|java|code)$"
          "--avoid"
          "^(.?kwin_wayland.*|.?plasmashell.*|Xwayland|sddm|systemd|.?sunshine.*)$"
        ];
      };

      pcscd = {
        enable = true;
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };

    environment.pathsToLink = ["/share/zsh"];
  };
}
