{...}: {
  flake.nixosModules.adguardhome = {
    config,
    lib,
    ...
  }: let
    cfg = config.doggate.adguardhome;
  in {
    options.doggate.adguardhome = {
      adminUser = lib.mkOption {
        type = lib.types.str;
        default = "misty";
        description = "Username for the AdGuard Home web interface.";
      };

      adminPasswordHash = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "$2y$10$...";
        description = ''
          bcrypt hash for the web interface login. While null, the web
          interface listens on 127.0.0.1 only (reach it with
          `ssh -L 3000:localhost:3000 <host>`), so an unauthenticated UI is
          never exposed to the LAN. Generate a hash with
          `nix-shell -p apacheHttpd --run 'htpasswd -nbBC 10 "" PASSWORD | tr -d ":\n"'`.
        '';
      };

      queryLogRetention = lib.mkOption {
        type = lib.types.str;
        default = "24h";
        description = ''
          How long AdGuard Home keeps the query log on local disk. Keep this
          short on small SD cards; ship the log elsewhere with
          `doggate.logShipping` for long-term history.
        '';
      };
    };

    config = {
      services.adguardhome = {
        enable = true;
        # With mutableSettings the declared settings below are merged over the
        # on-disk config at every start, so UI changes to other keys persist.
        mutableSettings = true;
        host = "0.0.0.0";

        port = 3000;
        openFirewall = true;

        settings = {
          dns = {
            bind_hosts = ["0.0.0.0"];
            port = 53;
            upstream_dns = [
              "https://dns.cloudflare.com/dns-query"
              "https://dns.quad9.net/dns-query"
            ];
            bootstrap_dns = ["1.1.1.1" "9.9.9.9"];
            protection_enabled = true;
          };

          filtering = {
            filtering_enabled = true;
            filters_update_interval = 24;
          };

          filters = [
            {
              enabled = true;
              id = 1;
              name = "AdGuard DNS filter";
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            }
          ];

          # Query log: small local window, history lives off-box (see
          # doggate.logShipping). size_memory is the in-RAM list the UI shows.
          querylog = {
            enabled = true;
            file_enabled = true;
            interval = cfg.queryLogRetention;
            size_memory = 1000;
          };

          statistics = {
            enabled = true;
            interval = "24h";
          };

          users = [
            {
              name = cfg.adminUser;
              password = cfg.adminPasswordHash;
            }
          ];
        };
      };

      # DNS for LAN clients.
      networking.firewall.allowedTCPPorts = [53];
      networking.firewall.allowedUDPPorts = [53];

      # Run as a static user (the nixpkgs unit uses DynamicUser) so the log
      # shipper can be granted read access to the query log via a group.
      users.users.adguardhome = {
        isSystemUser = true;
        group = "adguardhome";
      };
      users.groups.adguardhome = {};

      # The bind address comes from DHCP, so wait until the network is up.
      systemd.services.adguardhome.after = ["network-online.target"];
      systemd.services.adguardhome.wants = ["network-online.target"];

      services.resolved.settings.Resolve.DNSStubListener = lib.mkForce "no";

      systemd.services.adguardhome.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "adguardhome";
        Group = "adguardhome";
        StateDirectoryMode = "0750";
        UMask = lib.mkForce "0027";
      };

      # Let Alloy read /var/lib/AdGuardHome/data/querylog.json when it runs.
      systemd.services.alloy = lib.mkIf config.services.alloy.enable {
        serviceConfig.SupplementaryGroups = ["adguardhome"];
      };
    };
  };
}
