{...}: {
  # Receiver: Loki, reachable over WireGuard only. Query it with `logcli`
  # (installed by the module), e.g.
  #   logcli --addr=http://localhost:3100 query '{job="adguard-querylog"}'
  flake.nixosModules.loki-server = {...}: {
    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;

        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 3100;
        };

        common = {
          instance_addr = "127.0.0.1";
          path_prefix = "/var/lib/loki";
          storage.filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
          replication_factor = 1;
          ring.kvstore.store = "inmemory";
        };

        schema_config.configs = [
          {
            from = "2024-04-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        limits_config.retention_period = "720h"; # 30 days

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          retention_enabled = true;
          delete_request_store = "filesystem";
        };

        analytics.reporting_enabled = false;
      };
    };

    # Port is not opened on LAN interfaces, only on WireGuard.
    networking.firewall.interfaces."wg0".allowedTCPPorts = [3100];
  };

  # Sender: Grafana Alloy ships the journal (plus any extra files) to Loki.
  flake.nixosModules.log-shipper = {
    config,
    lib,
    ...
  }: let
    cfg = config.doggate.logShipping;

    fileTargets =
      lib.concatMapStringsSep "\n    "
      (f: ''{ __path__ = "${f.path}", job = "${f.job}" },'')
      cfg.files;
  in {
    options.doggate.logShipping = {
      lokiUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://10.100.0.2:3100/loki/api/v1/push";
        description = "Loki push endpoint (thekennel over WireGuard).";
      };

      files = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              description = "File to tail.";
            };
            job = lib.mkOption {
              type = lib.types.str;
              description = "Value of the `job` label for this file.";
            };
          };
        });
        default = [];
        description = "Extra files to tail and ship besides the journal.";
      };
    };

    config = {
      services.alloy = {
        enable = true;
        extraFlags = ["--disable-reporting"];
      };

      environment.etc."alloy/config.alloy".text = ''
        loki.write "kennel" {
          endpoint {
            url = "${cfg.lokiUrl}"
          }
          external_labels = {
            host = "${config.networking.hostName}",
          }
        }

        loki.relabel "journal" {
          forward_to = []
          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }
        }

        loki.source.journal "journal" {
          max_age       = "12h"
          labels        = { job = "systemd-journal" }
          relabel_rules = loki.relabel.journal.rules
          forward_to    = [loki.write.kennel.receiver]
        }
        ${lib.optionalString (cfg.files != []) ''

          local.file_match "files" {
            path_targets = [
              ${fileTargets}
            ]
          }

          loki.source.file "files" {
            targets    = local.file_match.files.targets
            forward_to = [loki.write.kennel.receiver]
          }
        ''}
      '';
    };
  };
}
