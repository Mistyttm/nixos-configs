{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

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

    # VPN-Confinement names the namespace's WireGuard interface "<namespace>0"
    vpnIface = "wg00";

    natpmpScript = pkgs.writeShellScript "qbt-natpmp" ''
      set -uo pipefail

      API="http://127.0.0.1:${toString qbtWebuiPort}/api/v2"
      COOKIE=$(mktemp)
      trap 'rm -f "$COOKIE"' EXIT

      login() {
        ${pkgs.curl}/bin/curl -s -c "$COOKIE" \
          --data-urlencode "username=admin" \
          --data-urlencode "password=$(cat ${config.sops.secrets."qbittorrent_password".path})" \
          "$API/auth/login" >/dev/null
      }

      get_port() {
        login
        ${pkgs.curl}/bin/curl -s -b "$COOKIE" "$API/app/preferences" \
          | ${pkgs.jq}/bin/jq -r '.listen_port // empty'
      }

      set_port() {
        login
        ${pkgs.curl}/bin/curl -s -b "$COOKIE" \
          --data-urlencode "json={\"listen_port\":$1,\"upnp\":false}" \
          "$API/app/setPreferences" >/dev/null
      }

      # The namespace drops all inbound traffic on the VPN interface by default,
      # so the Proton-assigned port has to be opened here, not via openVPNPorts.
      opened=""
      open_port() {
        local p
        if [ -n "$opened" ] && [ "$opened" != "$1" ]; then
          for p in tcp udp; do
            ${pkgs.iptables}/bin/iptables -D INPUT -i ${vpnIface} -p "$p" --dport "$opened" -j ACCEPT 2>/dev/null || true
          done
        fi
        for p in tcp udp; do
          ${pkgs.iptables}/bin/iptables -C INPUT -i ${vpnIface} -p "$p" --dport "$1" -j ACCEPT 2>/dev/null \
            || ${pkgs.iptables}/bin/iptables -A INPUT -i ${vpnIface} -p "$p" --dport "$1" -j ACCEPT
        done
        opened="$1"
      }

      while true; do
        mapped=""
        for proto in tcp udp; do
          out=$(${pkgs.libnatpmp}/bin/natpmpc -g ${natPmpGateway} \
                  -a ${toString qbtListenPort} ${toString qbtListenPort} "$proto" 60 2>&1) || true
          port=$(echo "$out" | grep -oP 'Mapped public port \K[0-9]+' || true)
          [ -n "$port" ] && mapped="$port"
        done

        if [ -n "$mapped" ]; then
          [ "$mapped" != "$opened" ] && echo "qbt-natpmp: opening mapped port $mapped on ${vpnIface}"
          open_port "$mapped"
          # Check qBittorrent's actual port every loop: a qBittorrent restart
          # rewrites its config back to the declarative Port.
          current=$(get_port || true)
          if [ -n "$current" ] && [ "$current" != "$mapped" ]; then
            echo "qbt-natpmp: qBittorrent on $current, setting $mapped"
            set_port "$mapped"
          fi
        else
          echo "qbt-natpmp: no mapping from gateway: $out"
        fi
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

      # The torrent port is assigned by Proton NAT-PMP at runtime and opened by
      # qbittorrent-natpmp, so it can't be listed statically in openVPNPorts.
    };

    systemd.services.qbittorrent.vpnConfinement = lib.mkIf config.services.qbittorrent.enable {
      enable = true;
      vpnNamespace = "wg0";
    };

    systemd.services.qbittorrent-natpmp = lib.mkIf config.services.qbittorrent.enable {
      description = "Proton NAT-PMP port forwarding for qBittorrent";
      after = ["qbittorrent.service"];
      wants = ["qbittorrent.service"];
      partOf = ["qbittorrent.service"];
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
