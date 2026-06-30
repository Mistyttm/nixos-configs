{self, ...}: {
  flake.nixosModules.fail2ban = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hostName = config.networking.hostName or "";

    relayScript = pkgs.writeText "fail2ban-relay.py" (builtins.readFile ./fail2ban-relay.py);
  in {
    sops.secrets."fail2ban-relay-token" = {
      sopsFile = self.secrets.fail2ban;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    config = lib.mkMerge [
      (lib.mkIf (hostName == "thedogpark") {
        systemd.services.fail2ban-relay = {
          description = "fail2ban ban relay (wg0-only)";
          after = ["wireguard-wg0.service"];
          wants = ["wireguard-wg0.service"];
          wantedBy = ["multi-user.target"];
          environment = {
            TOKEN_FILE = config.sops.secrets."fail2ban-relay-token".path;
            BIND_ADDR = "10.100.0.1";
            BIND_PORT = "9898";
          };
          serviceConfig = {
            ExecStart = "${pkgs.python3}/bin/python3 ${relayScript}";
            Restart = "always";
            DynamicUser = false; # needs root for iptables
            AmbientCapabilities = ["CAP_NET_ADMIN"];
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
          };
        };
      })

      (lib.mkIf (hostName == "thekennel") {
        services.fail2ban = {
          enable = true;
          bantime-increment.enable = true;

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
          actionban = ${pkgs.curl}/bin/curl -sf -X POST http://10.100.0.1:9898/ban \
                        -H "Authorization: Bearer $(cat ${config.sops.secrets."fail2ban-relay-token".path})" \
                        -H "Content-Type: application/json" \
                        -d '{"jail": "<name>", "ip": "<ip>"}'

          actionunban = ${pkgs.curl}/bin/curl -sf -X POST http://10.100.0.1:9898/unban \
                        -H "Authorization: Bearer $(cat ${config.sops.secrets."fail2ban-relay-token".path})" \
                        -H "Content-Type: application/json" \
                        -d '{"jail": "<name>", "ip": "<ip>"}'
        '';
      })
    ];
  };
}
