{ self, ... }:
{
  flake.nixosModules.wireguard =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      hostName = config.networking.hostName or "";

      thedogpark = {
        publicKey = "azW44KgfL9wjmY/XMlO8vhKUuJVomRB5U6PtGYJYlg8=";
        endpoint = "mistyttm.dev:51820";
        allowedIPs = [ "10.100.0.0/24" ];
        persistentKeepalive = 25;
        dynamicEndpointRefreshSeconds = 30;
      };

      profiles = {
        # Template profile for puppypc.
        puppypc = {
          allowedUDPPorts = [ ];
          interfaces.wg0 = {
            ips = [ "10.100.0.4/24" ];
            privateKeyFile = config.sops.secrets."puppypc_key".path;

            peers = [
              thedogpark
            ];
          };
        };

        # Template profile for puppylaptop.
        puppylaptop = {
          allowedUDPPorts = [ ];
          interfaces.wg0 = {
            ips = [ "10.100.0.3/24" ];
            privateKeyFile = config.sops.secrets."laptop_key".path;

            peers = [
              thedogpark
            ];
          };
        };

        # Template profile for thedogpark.
        thedogpark = {
          allowedUDPPorts = [ 51820 ];
          trustedInterfaces = [ "wg0" ];
          interfaces.wg0 = {
            ips = [ "10.100.0.1/24" ];
            listenPort = 51820;
            privateKeyFile = config.sops.secrets."dogpark_key".path;

            peers = [
              {
                # thekennel - home server
                publicKey = "PV35fOdFKVsftJ7lh+xVTYxDY9fw4mgN9hwlrDOnzlk=";
                allowedIPs = [ "10.100.0.2/32" ];
              }
              {
                # puppypc - home desktop
                publicKey = "3P03yC/x9XLleiWhb3KgiiF9Jei69eMOVOzaqczW5QQ=";
                allowedIPs = [ "10.100.0.3/32" ];
              }
              {
                # pupppylaptop - laptop
                publicKey = "YLEqUsdRe8LCXOHK6/8ct3ncSaaCqAoQLjiWWeGVl2s=";
                allowedIPs = [ "10.100.0.4/32" ];
              }
            ];
          };
        };

        thekennel = {
          allowedUDPPorts = [ ];
          interfaces.wg0 = {
            ips = [ "10.100.0.2/24" ];
            privateKeyFile = config.sops.secrets."thekennel_key".path;

            peers = [
              thedogpark
            ];
          };
        };
      };

      cfg = config.doggate.wireguard;
      selectedProfileName = if cfg.profile == null then hostName else cfg.profile;
      profile = profiles.${selectedProfileName} or null;
    in
    {
      options.doggate.wireguard = {
        enable = lib.mkEnableOption "Unified, host-profile-driven WireGuard configuration";

        profile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "thekennel";
          description = "Profile name to use. Defaults to networking.hostName.";
        };

        extraAllowedUDPPorts = lib.mkOption {
          type = lib.types.listOf lib.types.port;
          default = [ ];
          description = "Extra UDP ports to open in addition to the selected profile.";
        };

        extraInterfaces = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Extra or overriding networking.wireguard.interfaces entries.";
        };
      };

      config = lib.mkIf (cfg.enable && profile != null) {
        sops.secrets."laptop_key" = {
          sopsFile = self.secrets.wireguard;
          owner = "root";
          group = "root";
        };

        sops.secrets."puppypc_key" = {
          sopsFile = self.secrets.wireguard;
          owner = "root";
          group = "root";
        };

        sops.secrets."thekennel_key" = {
          sopsFile = self.secrets.wireguard;
          owner = "root";
          group = "root";
        };

        sops.secrets."dogpark_key" = {
          sopsFile = self.secrets.wireguard;
          owner = "root";
          group = "root";
        };

        environment.systemPackages = with pkgs; [
          wireguard-tools
        ];

        networking.wireguard = {
          enable = true;
          interfaces.wg0 = lib.mkMerge [
            (profile.interfaces.wg0 or { })
            cfg.extraInterfaces
          ];
        };

        systemd.services.wireguard-wg0 = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };

        networking.firewall.allowedUDPPorts = (profile.allowedUDPPorts or [ ]) ++ cfg.extraAllowedUDPPorts;

        networking.firewall.trustedInterfaces = profile.trustedInterfaces or [ ];
      };
    };
}
