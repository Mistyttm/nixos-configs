{ self, ... }:
{

  flake.nixosModules.thedogparkConfiguration =
    { pkgs, ... }:
    {
      # import any other modules from here
      imports = with self.nixosModules; [
        thedogparkHardware
        thedogparkHomeManager
        system-essentials
        misty
        docker
        fonts
        cli-tools
        bat
        nix-ld
        mullvad
        fail2ban
        matrix
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

      programs.java.enable = true;

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

      nixpkgs.config = {
        permittedInsecurePackages = [
          "olm-3.2.16"
        ];
      };

      system.stateVersion = "25.11";
    };

}
