{self, ...}: {
  flake.nixosModules.thedogparkConfiguration = {pkgs, ...}: {
    # import any other modules from here
    imports = with self.nixosModules; [
      thedogparkHardware
      thedogparkHomeManager
      system-essentials
      misty
      docker
      fonts
      cli-tools
      nix-ld
      fail2ban
      matrix
      motd
      prometheus-exporter
    ];

    networking.hostName = "thedogpark";

    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
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
      nodejs
      direnv
      nil
      packwiz
      cron
      nix-ld
      tmux
      nano
    ];

    networking.firewall.allowedTCPPorts = [
      5173
      24464
      8448
      443
      3478
      5349
      9005
      8888
    ];
    networking.firewall.allowedUDPPorts = [
      5173
      24464
      3478
      5349
    ];
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 2456;
        to = 2458;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 2456;
        to = 2458;
      }
      {
        from = 49152;
        to = 65535;
      }
    ];

    programs.nh.flake = "/home/misty/nixos-configs";

    nixpkgs.config = {
      permittedInsecurePackages = [
        "olm-3.2.16"
      ];
    };

    systemd.services.mistyttmpersonalsite = {
      description = "Build and run Vite for the MistyTTM Personal Site in production mode";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bash}/bin/bash -c 'cd /home/misty/Documents/mistyttmpersonalsite && ${pkgs.nodejs}/bin/npx vite --mode production --port 8080'";
        WorkingDirectory = "/home/misty/Documents/mistyttmpersonalsite";
        Restart = "on-failure";
        # AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        User = "misty";
        Group = "users";
        Environment = "PATH=${pkgs.nodejs}/bin:${pkgs.nodejs}/lib/node_modules/.bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
      };
    };

    system.stateVersion = "25.11";
  };
}
