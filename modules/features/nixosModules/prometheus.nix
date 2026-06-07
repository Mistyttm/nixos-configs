{...}: {
  flake.nixosModules.prometheus-exporter = {
    config,
    lib,
    ...
  }: {
    options.monitoring.wireguardIP = lib.mkOption {
      type = lib.types.str;
      description = "WireGuard interface IP to bind exporters to";
    };

    config = {
      services.prometheus.exporters = {
        node = {
          enable = true;
          port = 9100;
          listenAddress = config.monitoring.wireguardIP;
          enabledCollectors = ["systemd"];
        };
        nginx = {
          enable = true;
          port = 9113;
          listenAddress = config.monitoring.wireguardIP;
        };
        wireguard = {
          enable = true;
          port = 9586;
          listenAddress = config.monitoring.wireguardIP;
        };
      };

      services.nginx.statusPage = true;

      # only reachable over WireGuard, but open the ports on that interface
      networking.firewall.interfaces."wg0".allowedTCPPorts = [9100 9113 9586 9148];
    };
  };

  flake.nixosModules.prometheus-server = {
    config,
    lib,
    ...
  }: {
    options.monitoring.scrapeTargets = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [];
      description = "Additional Prometheus scrape configs";
    };

    config = {
      services.prometheus = {
        enable = true;
        port = 9090;

        # local exporters on thekennel
        exporters = {
          node = {
            enable = true;
            port = 9100;
            enabledCollectors = ["systemd"];
          };
          nginx = {
            enable = true;
            port = 9113;
          };
          wireguard = {
            enable = true;
            port = 9586;
          };
        };

        scrapeConfigs =
          [
            {
              job_name = "thekennel";
              static_configs = [
                {
                  targets = [
                    "localhost:9100"
                    "localhost:9113"
                    "localhost:9586"
                  ];
                }
              ];
            }
          ]
          ++ config.monitoring.scrapeTargets;
      };

      networking.firewall.allowedTCPPorts = [config.services.prometheus.port];
    };
  };
}
