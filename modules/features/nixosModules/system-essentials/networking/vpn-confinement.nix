{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.vpn-confinement = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Proton's WireGuard gateway address inside the tunnel (from the wg config's DNS/Address block)
    natPmpGateway = "10.2.0.1";
    qbtListenPort = config.services.qbittorrent.serverConfig.BitTorrent.Session.Port; # must match BitTorrent.Session.Port
    qbtWebuiPort = config.services.qbittorrent.webuiPort;

    natpmpScript = pkgs.writeShellScript "qbt-natpmp" ''
      set -uo pipefail

      COOKIE=$(mktemp)
      trap 'rm -f "$COOKIE"' EXIT

      login() {
        ${pkgs.curl}/bin/curl -s -c "$COOKIE" \
          --data-urlencode "username=admin" \
          --data-urlencode "password=$(cat ${config.sops.secrets."qbittorrent_password".path})" \
          "http://127.0.0.1:${toString qbtWebuiPort}/api/v2/auth/login" >/dev/null
      }

      set_port() {
        login
        ${pkgs.curl}/bin/curl -s -b "$COOKIE" \
          --data-urlencode "json={\"listen_port\":$1,\"upnp\":false}" \
          "http://127.0.0.1:${toString qbtWebuiPort}/api/v2/app/setPreferences" >/dev/null
      }

      last_port=""
      while true; do
        for proto in tcp udp; do
          out=$(${pkgs.libnatpmp}/bin/natpmpc -g ${natPmpGateway} \
                  -a ${toString qbtListenPort} ${toString qbtListenPort} "$proto" 60 2>&1) || true
          mapped=$(echo "$out" | grep -oP 'Mapped public port \K[0-9]+' || true)
          if [ -n "$mapped" ] && [ "$mapped" != "$last_port" ]; then
            echo "qbt-natpmp: new mapped port $mapped ($proto), pushing to qBittorrent"
            set_port "$mapped"
            last_port="$mapped"
          fi
        done
        sleep 45
      done
    '';
  in {
    sops.secrets.protonvpn-wg-conf = {
      sopsFile = self.secrets.protonvpn;
      mode = "0400";
    };
    sops.secrets."qbittorrent_password" = {
      sopsFile = self.secrets.media;
      mode = "0400";
    };

    imports = [
      inputs.vpn-confinement.nixosModules.default
    ];

    vpnNamespaces.wg0 = {
      enable = true;
      wireguardConfigFile = config.sops.secrets.protonvpn-wg-conf.path;
      # LAN allowed to reach the confined services' WebUIs
      accessibleFrom = [
        "192.168.0.0/24"

        "10.100.0.0/24"
      ];

      portMappings = [
        {
          from = 8080;
          to = 8080;
        } # qBittorrent WebUI
      ];

      # torrent listening port, forwarded through the VPN itself
      openVPNPorts = [
        {
          port = 51413;
          protocol = "both";
        }
      ];
    };

    systemd.services.qbittorrent.vpnConfinement = lib.mkIf config.services.qbittorrent.enable {
      enable = true;
      vpnNamespace = "wg0";
    };

    systemd.services.qbittorrent-natpmp = lib.mkIf config.services.qbittorrent.enable {
      description = "Proton NAT-PMP port forwarding for qBittorrent";
      after = ["qbittorrent.service"];
      wants = ["qbittorrent.service"];
      wantedBy = ["multi-user.target"];

      vpnConfinement = {
        enable = true;
        vpnNamespace = "wg0";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${natpmpScript}";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
}
