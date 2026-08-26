{self, ...}: {
  flake.nixosModules.prometheus-alerting = {config, ...}: {
    sops.secrets."matrix-alertmanager-secret-alertmanager-copy" = {
      sopsFile = self.secrets.matrix-alertmanager;
      key = "secret";
      # services.prometheus.alertmanager runs under DynamicUser=true, and
      # unlike your fail2ban-relay there's no LoadCredential hook exposed
      # for webhook_configs.password_file — so this has to be world-
      # readable inside /run/secrets rather than owner-restricted. It's a
      # shared token gating who can post fake alerts into the room, not a
      # homeserver credential, so the exposure is low but worth knowing.
      mode = "0444";
    };

    services.prometheus.alertmanager = {
      enable = true;
      port = 9093;
      listenAddress = "10.100.0.1";

      configuration = {
        route = {
          receiver = "infra-alerts";
          group_by = ["alertname" "instance"];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
        };
        receivers = [
          {
            name = "infra-alerts";
            webhook_configs = [
              {
                url = "http://127.0.0.1:${toString config.services.matrix-alertmanager.port}/alerts";
                http_config.basic_auth = {
                  username = "alertmanager";
                  password_file = config.sops.secrets."matrix-alertmanager-secret-alertmanager-copy".path;
                };
              }
            ];
          }
        ];
      };
    };

    services.prometheus.rules = [
      (builtins.toJSON {
        groups = [
          {
            name = "infra-health";
            rules = [
              {
                alert = "InstanceDown";
                expr = "up == 0";
                for = "5m";
                labels.severity = "critical";
                annotations.summary = "{{ $labels.job }} on {{ $labels.instance }} has been down for 5m.";
              }
              {
                alert = "HostDiskSpaceLow";
                expr = ''(node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"}) < 0.10'';
                for = "15m";
                labels.severity = "warning";
                annotations.summary = "{{ $labels.instance }} has less than 10% free on {{ $labels.mountpoint }}.";
              }
              {
                alert = "HostHighMemoryUsage";
                expr = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.90";
                for = "15m";
                labels.severity = "warning";
                annotations.summary = "{{ $labels.instance }} is above 90% memory usage.";
              }
            ];
          }
        ];
      })
    ];

    networking.firewall.interfaces."wg0".allowedTCPPorts = [config.services.prometheus.alertmanager.port];
  };
}
