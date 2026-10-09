{self, ...}: {
  flake.nixosModules.fail2ban = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hostName = config.networking.hostName or "";
    relayScript = pkgs.writeText "fail2ban-relay.py" (builtins.readFile ./fail2ban-relay.py);

    # Known jails get their chains created declaratively, once, at firewall
    # build time -- the relay only ever inserts/deletes rules inside them.
    knownJails = ["jellyfin"];

    jailChainCommands =
      lib.concatMapStringsSep "\n" (name: ''
        iptables -N f2b-${name} 2>/dev/null || true
        iptables -C INPUT -j f2b-${name} 2>/dev/null || iptables -I INPUT -j f2b-${name}
      '')
      knownJails;
  in {
    config = lib.mkMerge [
      {
        sops.secrets."fail2ban-relay-token" = {
          sopsFile = self.secrets.fail2ban;
          owner = "root";
          group = "root";
          mode = "0400";
        };

        services.fail2ban = {
          enable = true;
          bantime-increment.enable = true;
        };

        networking.firewall.extraCommands = jailChainCommands;
      }

      (lib.mkIf (hostName == "thedogpark") {
        networking.firewall.extraCommands = ''
          ${jailChainCommands}
          iptables -I nixos-fw 1 -i wg0 -p tcp --dport 9898 ! -s 10.100.0.2 -j DROP
        '';

        systemd.services.fail2ban-relay = {
          description = "fail2ban ban relay (wg0-only)";
          after = ["wireguard-wg0.service"];
          wants = ["wireguard-wg0.service"];
          wantedBy = ["multi-user.target"];
          environment = {
            TOKEN_FILE = config.sops.secrets."fail2ban-relay-token".path;
            BIND_ADDR = "10.100.0.1";
            BIND_PORT = "9898";
            ALLOWED_PEER = "10.100.0.2";
          };
          serviceConfig = {
            ExecStart = "${pkgs.python3}/bin/python3 ${relayScript}";
            Restart = "always";
            User = "fail2ban-relay";
            DynamicUser = true;
            LoadCredential = "token:${config.sops.secrets."fail2ban-relay-token".path}";
            AmbientCapabilities = ["CAP_NET_ADMIN"];
            CapabilityBoundingSet = ["CAP_NET_ADMIN"];
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
          };
        };
      })

      (lib.mkIf (hostName == "thekennel") {
        services.fail2ban = {
          jails.jellyfin.settings = {
            enabled = true;
            filter = "jellyfin";
            port = "8096,8097";
            protocol = "tcp";
            maxretry = 3;
            bantime = 86400;
            findtime = 43200;
            logpath = "${config.services.jellyfin.dataDir}/log/log_*.log";
            action = "proxy-http-relay";
          };
        };

        environment.etc."fail2ban/filter.d/jellyfin.conf".text = ''
          [Definition]
          failregex = ^.*Authentication request for .* has been denied \(IP: "<ADDR>"\)\.
        '';

        environment.etc."fail2ban/action.d/proxy-http-relay.conf".text = ''
          [Definition]
          actionban = iptables -N f2b-<name> 2>/dev/null || true
                      iptables -C INPUT -j f2b-<name> 2>/dev/null || iptables -I INPUT -j f2b-<name>
                      iptables -C f2b-<name> -s <ip> -j DROP 2>/dev/null || iptables -I f2b-<name> 1 -s <ip> -j DROP
                      ${pkgs.curl}/bin/curl -sf -X POST http://10.100.0.1:9898/ban \
                        -H "Authorization: Bearer $(cat ${config.sops.secrets."fail2ban-relay-token".path})" \
                        -H "Content-Type: application/json" \
                        -d '{"jail": "<name>", "ip": "<ip>"}'

          actionunban = iptables -D f2b-<name> -s <ip> -j DROP
                        ${pkgs.curl}/bin/curl -sf -X POST http://10.100.0.1:9898/unban \
                        -H "Authorization: Bearer $(cat ${config.sops.secrets."fail2ban-relay-token".path})" \
                        -H "Content-Type: application/json" \
                        -d '{"jail": "<name>", "ip": "<ip>"}'
        '';
      })
    ];
  };
}
