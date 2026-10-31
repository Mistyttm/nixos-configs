{self, ...}: {
  flake.nixosModules.crowdsec = {
    config,
    lib,
    ...
  }: let
    cfg = config.doggate.crowdsec;
    nginxEnabled = config.services.nginx.enable;
    crowdsecCfg = config.services.crowdsec;

    # 4h on first offence, +4h per prior decision still in the database
    # (flushed after 7 days), capped at 24h. Must not contain `%`: the upstream
    # module writes profiles.yaml via tmpfiles, which treats `%d` (as in
    # Sprintf('%dh')) as a specifier and silently skips the file.
    banDurationExpr = "GetDecisionsCount(Alert.GetValue()) >= 5 ? '24h' : string((GetDecisionsCount(Alert.GetValue()) + 1) * 4) + 'h'";
    mkBanProfile = scope: {
      name = "default_${lib.toLower scope}_remediation";
      filters = ["Alert.Remediation == true && Alert.GetScope() == '${scope}'"];
      decisions = [
        {
          type = "ban";
          duration = "4h";
        }
      ];
      duration_expr = banDurationExpr;
      on_success = "break";
    };

    trustedRoutesExpr = lib.concatStringsSep " || " (lib.mapAttrsToList (
        host: prefixes: "(evt.Meta.target_fqdn == '${host}' && (${
          lib.concatMapStringsSep " || " (p: "evt.Meta.http_path startsWith '${p}'") prefixes
        }))"
      )
      cfg.trustedHttpRoutes);

    notFoundRoutesExpr = lib.concatStringsSep " || " (lib.mapAttrsToList (
        host: prefixes: "(evt.Meta.target_fqdn == '${host}' && (${
          lib.concatMapStringsSep " || " (p: "evt.Meta.http_path startsWith '${p}'") prefixes
        }))"
      )
      cfg.notFoundHttpRoutes);
  in {
    options.doggate.crowdsec = {
      enable = lib.mkEnableOption ''
        CrowdSec security engine with the iptables firewall bouncer. Parses
        sshd (and nginx, when enabled) logs, shares signals with the CrowdSec
        community, and pulls the community blocklist
      '';

      lapiPort = lib.mkOption {
        type = lib.types.port;
        # Upstream default is 8080, which collides with the personal site's
        # Vite server on thedogpark.
        default = 8180;
        description = "Port the local CrowdSec API listens on.";
      };

      trustedHttpRoutes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {};
        example = {
          "jellyfin.example.com" = ["/"];
          "example.com" = ["/_matrix/"];
        };
        description = ''
          nginx vhosts mapped to the path prefixes whose successful (2xx/3xx,
          or 429) responses CrowdSec ignores. Matched against the `$host`
          prefix this module adds to the nginx access log.
        '';
      };

      notFoundHttpRoutes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {};
        example = {
          "example.com" = ["/_matrix/client/v1/media/" "/_matrix/media/"];
        };
        description = ''
          nginx vhosts mapped to path prefixes whose 404 responses CrowdSec
          ignores. For apps where a 404 is routine client behaviour (Matrix
          remote media that can't be fetched, unstable feature probes), so a
          single page load can't trip http-probing. Keep these narrow: probing
          anywhere else on the vhost still counts.
        '';
      };

      trustedIps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["10.100.0.0/24" "203.0.113.7/32"];
        description = ''
          IPs/CIDRs CrowdSec never raises alerts for, so they can never be
          banned by the firewall bouncer (which would also cut WireGuard and
          SSH from that address).
        '';
      };

      console.enable = lib.mkEnableOption ''
        enrolling this engine in the CrowdSec web console (app.crowdsec.net),
        using the `crowdsec_enroll_key` entry in `secrets/crowdsec.yaml`
      '';

      homepage.enable = lib.mkEnableOption ''
        a `homepage` LAPI machine for the gethomepage.dev crowdsec widget. Its
        password is `crowdsec_homepage_password` in `secrets/crowdsec.yaml`.
        The LAPI then listens on all interfaces; only the trusted wg0
        interface lets it through the firewall
      '';
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        services.crowdsec = {
          enable = true;
          autoUpdateService = true;

          # nginx's LogsDirectory is nginx:nginx 0750
          extraGroups = ["systemd-journal"] ++ lib.optional nginxEnabled "nginx";
          readOnlyPaths = lib.optional nginxEnabled "/var/log/nginx";

          hub.collections =
            [
              "crowdsecurity/linux"
              "crowdsecurity/sshd"
            ]
            ++ lib.optionals nginxEnabled [
              "crowdsecurity/nginx"
              "crowdsecurity/base-http-scenarios"
              "crowdsecurity/http-cve"
            ];

          settings = {
            config.api.server = {
              listen_uri = "${
                if cfg.homepage.enable
                then "0.0.0.0"
                else "127.0.0.1"
              }:${toString cfg.lapiPort}";
              # Registers with the Central API on first start, which enables the
              # community blocklist.
              online_client.credentials_path = "${crowdsecCfg.settings.config.config_paths.data_dir}/online_api_credentials.yaml";
            };

            profiles = map mkBanProfile ["Ip" "Range"];

            # Self-hosted apps (Matrix media, Jellyfin posters, Seerr's API)
            # burst extensionless requests that http-crawl-non_statics reads as
            # crawling. Only non-error responses on trusted routes are dropped,
            # so 400/401/403/404 probing still counts.
            parsers.s02Enrich =
              lib.optional (nginxEnabled && cfg.trustedHttpRoutes != {}) {
                name = "doggate/trusted-http-routes";
                description = "Ignore successful requests to trusted vhosts/paths";
                whitelist = {
                  reason = "Trusted self-hosted app traffic";
                  expression = [
                    "evt.Meta.service == 'http' && evt.Meta.http_status matches '^([23][0-9][0-9]|429)$' && (${trustedRoutesExpr})"
                  ];
                };
              }
              # A Matrix client opening a room 404s on every avatar it can't
              # fetch from a remote server plus the MSC2965 auth_issuer probe,
              # which is enough on its own to trip http-probing.
              ++ lib.optional (nginxEnabled && cfg.notFoundHttpRoutes != {}) {
                name = "doggate/not-found-http-routes";
                description = "Ignore routine 404s on app routes";
                whitelist = {
                  reason = "Expected 404s from self-hosted app clients";
                  expression = [
                    "evt.Meta.service == 'http' && evt.Meta.http_status == '404' && (${notFoundRoutesExpr})"
                  ];
                };
              }
              ++ lib.optional (cfg.trustedIps != []) {
                name = "doggate/trusted-ips";
                description = "Never alert on trusted addresses";
                whitelist = {
                  reason = "Trusted address";
                  cidr = cfg.trustedIps;
                };
              };

            acquisitions =
              [
                {
                  source = "journalctl";
                  journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
                  labels.type = "syslog";
                }
              ]
              ++ lib.optional nginxEnabled {
                source = "file";
                filenames = ["/var/log/nginx/*.log"];
                labels.type = "nginx";
              };
          };
        };

        # Prefixing the access log with $host lets crowdsecurity/nginx-logs fill
        # evt.Meta.target_fqdn, which trustedHttpRoutes matches on. $host
        # rather than $server_name: requests with an unknown Host land on the
        # default vhost but keep their own Host, so they never match.
        services.nginx.commonHttpConfig = lib.mkIf nginxEnabled ''
          log_format crowdsec '$host $remote_addr - $remote_user [$time_local] '
                              '"$request" $status $body_bytes_sent '
                              '"$http_referer" "$http_user_agent"';
          access_log /var/log/nginx/access.log crowdsec;
        '';

        # Mode follows networking.nftables.enable (iptables on all current hosts);
        # registers itself against the local API automatically.
        services.crowdsec-firewall-bouncer = {
          enable = true;
          settings.api_url = "http://127.0.0.1:${toString cfg.lapiPort}";
        };
      }

      (lib.mkIf cfg.console.enable {
        # Read by crowdsec-setup through LoadCredential, so root-only is fine.
        sops.secrets."crowdsec_enroll_key" = {
          sopsFile = self.secrets.crowdsec;
        };

        services.crowdsec.settings.console.enrollKeyFile = config.sops.secrets."crowdsec_enroll_key".path;
      })

      (lib.mkIf cfg.homepage.enable {
        sops.secrets."crowdsec_homepage_password" = {
          sopsFile = self.secrets.crowdsec;
        };

        # (Re)creates the machine on every start so the password tracks the
        # sops value. `-f -` matters: without it cscli overwrites the engine's
        # own local_api_credentials.yaml.
        systemd.services.crowdsec-homepage-machine = rec {
          description = "Register the homepage dashboard as a CrowdSec LAPI machine";
          wantedBy = ["multi-user.target"];
          after = ["crowdsec.service"];
          wants = after;
          path = [crowdsecCfg.package];
          script = ''
            cscli machines add homepage --force -f - \
              --password "$(<"$CREDENTIALS_DIRECTORY/password")" >/dev/null
          '';
          serviceConfig = {
            Type = "oneshot";
            User = crowdsecCfg.user;
            Group = crowdsecCfg.group;
            DynamicUser = true;
            LoadCredential = "password:${config.sops.secrets."crowdsec_homepage_password".path}";
            ReadWritePaths = ["/var/lib/crowdsec"];
            PrivateDevices = true;
            ProtectHome = true;
            ProtectProc = "invisible";
            RestrictAddressFamilies = "none";
            CapabilityBoundingSet = [""];
            UMask = "0077";
          };
        };
      })
    ]);
  };
}
