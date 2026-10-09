{...}: {
  # Lean node exporter for small hosts. Unlike `prometheus-exporter` it does not
  # pull in the nginx/wireguard exporters or alerting.
  flake.nixosModules.node-exporter = {...}: {
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = ["systemd"];
    };

    # Only reachable over WireGuard.
    networking.firewall.interfaces."wg0".allowedTCPPorts = [9100];
  };
}
