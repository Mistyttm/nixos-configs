{...}: {
  flake.nixosModules.cleanuparr = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.cleanuparr;

    # Mirrors Cleanuparr.Shared.Helpers.BasePathValidator: must start with '/', contain no dots or double slashes, no trailing slash, and only letters/numbers/hyphens/underscores per path segment.
    basePathValid = p: p == null || builtins.match "/[a-zA-Z0-9_-]+(/[a-zA-Z0-9_-]+)*" p != null;
  in {
    options.services.cleanuparr = {
      enable = lib.mkEnableOption "Cleanuparr, an advanced download queue cleaner for the *arr ecosystem";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.cleanuparr;
        defaultText = lib.literalExpression "pkgs.cleanuparr";
        description = "Cleanuparr package to run.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the firewall for {option}`services.cleanuparr.settings.port`.";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/cleanuparr";
        description = ''
          Directory holding Cleanuparr's persistent state: `cleanuparr.json`,
          the sqlite database (when `settings.database.provider` is
          `sqlite`), the ASP.NET Data Protection keyring, and logs (unless
          {option}`services.cleanuparr.logsDir` is set separately).
          Passed to the app as `CLEANUPARR_CONFIG_PATH`; created and owned
          by {option}`services.cleanuparr.user`/{option}`services.cleanuparr.group`
          on service start.
        '';
      };

      logsDir = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/var/log/cleanuparr";
        description = ''
          Directory Cleanuparr writes its log files to, passed as
          `CLEANUPARR_LOGS_PATH`. Leave as `null` to let Cleanuparr keep
          logs under {option}`services.cleanuparr.dataDir` (its own
          default when the variable is unset).
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "cleanuparr";
        description = ''
          User account under which Cleanuparr runs. If left at the
          default, a system user of that name is created automatically
          and made the owner of {option}`services.cleanuparr.dataDir`.
        '';
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "cleanuparr";
        description = ''
          Group under which Cleanuparr runs. If left at the default, a
          system group of that name is created automatically. Set this to
          a shared group (e.g. `media`) if other *arr services need
          read/write access to files Cleanuparr touches.
        '';
      };

      settings = {
        port = lib.mkOption {
          type = lib.types.port;
          default = 11011;
          description = ''
            TCP port Cleanuparr's web UI and API listen on, passed as
            `PORT`. `11011` is Cleanuparr's own default.
          '';
        };

        bindAddress = lib.mkOption {
          type = lib.types.str;
          default = "0.0.0.0";
          example = "127.0.0.1";
          description = ''
            Address Cleanuparr binds to, passed as `BIND_ADDRESS`.
            `"0.0.0.0"` and `"*"` both mean "listen on every interface"
            (Kestrel's `ListenAnyIP`); anything else must parse as a
            literal IP address or Cleanuparr refuses to start.
          '';
        };

        basePath = lib.mkOption {
          type = lib.types.nullOr (lib.types.addCheck lib.types.str basePathValid);
          default = null;
          example = "/cleanuparr";
          description = ''
            URL path prefix to serve Cleanuparr under, e.g. behind a
            reverse proxy at `https://example.com/cleanuparr`, passed as
            `BASE_PATH`. Leave as `null` to serve from `/`.

            Must start with `/`, must not be `/` itself, must not end
            with a trailing slash, and may only contain letters, numbers,
            hyphens, and underscores per path segment (no dots, no `//`)
            — this mirrors Cleanuparr's own `BASE_PATH` validation, so an
            invalid value fails at evaluation time instead of at runtime.
          '';
        };

        database = {
          provider = lib.mkOption {
            type = lib.types.enum ["sqlite" "postgres"];
            default = "sqlite";
            description = ''
              Which database backend Cleanuparr uses, passed as
              `DATABASE_PROVIDER`. `sqlite` needs no further
              configuration and stores its database file under
              {option}`services.cleanuparr.dataDir`. `postgres` requires
              {option}`services.cleanuparr.settings.database.host`,
              `.user`, and `.database` to be set, and
              {option}`services.cleanuparr.settings.database.passwordFile`
              to point at a file containing the password.
            '';
          };

          host = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "localhost";
            description = ''
              Postgres host, passed as `POSTGRES_HOST`. Required when
              `provider` is `postgres`.
            '';
          };

          port = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = null;
            example = 5432;
            description = ''
              Postgres port, passed as `POSTGRES_PORT`. Optional — when
              unset, Npgsql's own default (5432) is used.
            '';
          };

          user = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Postgres username, passed as `POSTGRES_USER`. Required
              when `provider` is `postgres`.
            '';
          };

          database = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "cleanuparr";
            description = ''
              Postgres database name, passed as `POSTGRES_DB`. Required
              when `provider` is `postgres`.
            '';
          };

          passwordFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path to a file containing the Postgres password (e.g.
              managed by `sops-nix` or `agenix`). Read at service start
              via `LoadCredential` and exported to the process as
              `POSTGRES_PASS`, so the password itself never enters the
              Nix store and never appears in `systemctl show`/the unit
              file. Required when `provider` is `postgres`.
            '';
          };

          extraParams = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "SSL Mode=Require;Trust Server Certificate=true";
            description = ''
              Raw Npgsql connection-string fragment (`Key=Value;Key2=Value2`),
              passed as `POSTGRES_EXTRA_PARAMS` and merged in verbatim by
              Cleanuparr's own connection-string builder. Not validated
              at the Nix level — anything accepted by
              `NpgsqlConnectionStringBuilder` is accepted here too.
            '';
          };
        };
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to an `EnvironmentFile` (`KEY=value` per line) merged into
          the unit's environment at runtime. Use this for secrets or for
          any Cleanuparr environment variable not modelled by this
          module — it is not read or validated by Nix.
        '';
      };

      extraEnvironment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        example = lib.literalExpression ''
          {
            DOTNET_GCConserveMemory = "5";
            TZ = "Australia/Melbourne";
          }
        '';
        description = ''
          Extra environment variables to set for the Cleanuparr service,
          merged into `systemd.services.cleanuparr.environment`. For
          non-secret tuning values only — use
          {option}`services.cleanuparr.environmentFile` for anything
          sensitive.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.settings.database.provider == "postgres" -> cfg.settings.database.host != null;
          message = "services.cleanuparr.settings.database.host must be set when provider is \"postgres\".";
        }
        {
          assertion = cfg.settings.database.provider == "postgres" -> cfg.settings.database.user != null;
          message = "services.cleanuparr.settings.database.user must be set when provider is \"postgres\".";
        }
        {
          assertion = cfg.settings.database.provider == "postgres" -> cfg.settings.database.database != null;
          message = "services.cleanuparr.settings.database.database must be set when provider is \"postgres\".";
        }
        {
          assertion = cfg.settings.database.provider == "postgres" -> cfg.settings.database.passwordFile != null;
          message = "services.cleanuparr.settings.database.passwordFile must be set when provider is \"postgres\".";
        }
      ];

      users.users = lib.mkIf (cfg.user == "cleanuparr") {
        cleanuparr = {
          isSystemUser = true;
          group = cfg.group;
          home = cfg.dataDir;
        };
      };

      users.groups = lib.mkIf (cfg.group == "cleanuparr") {
        cleanuparr = {};
      };

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.settings.port];

      # Owns dataDir/logsDir regardless of whether they're left at their defaults or pointed somewhere custom by the user.
      systemd.tmpfiles.rules =
        ["d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} - -"]
        ++ lib.optional (cfg.logsDir != null) "d ${cfg.logsDir} 0750 ${cfg.user} ${cfg.group} - -";

      systemd.services.cleanuparr = {
        description = "Cleanuparr";
        after = ["network.target"] ++ lib.optional (cfg.settings.database.provider == "postgres") "postgresql.service";
        wantedBy = ["multi-user.target"];

        environment =
          {
            PORT = toString cfg.settings.port;
            BIND_ADDRESS = cfg.settings.bindAddress;
            CLEANUPARR_CONFIG_PATH = cfg.dataDir;
            DATABASE_PROVIDER = cfg.settings.database.provider;
          }
          // lib.optionalAttrs (cfg.settings.basePath != null) {
            BASE_PATH = cfg.settings.basePath;
          }
          // lib.optionalAttrs (cfg.logsDir != null) {
            CLEANUPARR_LOGS_PATH = cfg.logsDir;
          }
          // lib.optionalAttrs (cfg.settings.database.provider == "postgres") (
            {
              POSTGRES_HOST = cfg.settings.database.host;
              POSTGRES_USER = cfg.settings.database.user;
              POSTGRES_DB = cfg.settings.database.database;
            }
            // lib.optionalAttrs (cfg.settings.database.port != null) {
              POSTGRES_PORT = toString cfg.settings.database.port;
            }
            // lib.optionalAttrs (cfg.settings.database.extraParams != null) {
              POSTGRES_EXTRA_PARAMS = cfg.settings.database.extraParams;
            }
          )
          // cfg.extraEnvironment;

        # Cleanuparr only reads POSTGRES_PASS as a plain environment
        # variable, not from a credentials-directory path, so the
        # LoadCredential'd file has to be turned into an env var at start.
        # Everything else is set declaratively via `environment` above.
        script =
          if cfg.settings.database.passwordFile != null
          then ''
            export POSTGRES_PASS="$(cat "$CREDENTIALS_DIRECTORY/postgres-pass")"
            exec ${cfg.package}/bin/Cleanuparr
          ''
          else ''
            exec ${cfg.package}/bin/Cleanuparr
          '';

        serviceConfig =
          {
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = cfg.dataDir;
            Restart = "on-failure";

            # Hardening
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [cfg.dataDir] ++ lib.optional (cfg.logsDir != null) cfg.logsDir;
          }
          // lib.optionalAttrs (cfg.environmentFile != null) {
            EnvironmentFile = cfg.environmentFile;
          }
          // lib.optionalAttrs (cfg.settings.database.passwordFile != null) {
            LoadCredential = ["postgres-pass:${cfg.settings.database.passwordFile}"];
          };
      };
    };
  };
}
