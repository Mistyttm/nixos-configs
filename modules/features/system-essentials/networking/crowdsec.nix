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
    # (flushed after 7 days), capped at 24h.
    banDurationExpr = "GetDecisionsCount(Alert.GetValue()) >= 5 ? '24h' : Sprintf('%dh', (GetDecisionsCount(Alert.GetValue()) + 1) * 4)";
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
