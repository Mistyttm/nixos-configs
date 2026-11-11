{...}: {
  flake.nixosModules.dispatcharr = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.dispatcharr;
    pkg = cfg.package;
    inherit (pkg) python;
    app = "${pkg}/share/dispatcharr";
    redis = config.services.redis.servers.dispatcharr;

    defaultUser = "dispatcharr";
    defaultGroup = "dispatcharr";

    # StateDirectory= only manages paths below /var/lib.
    stateDir = lib.removePrefix "/var/lib/" cfg.dataDir;
    useStateDirectory = lib.hasPrefix "/var/lib/" cfg.dataDir;

    # Upstream hardcodes these below /data; each unit gets dataDir bound there.
    dataSubdirs = [
      "backups"
      "cache"
      "epgs"
      "logos"
      "logs"
      "m3us"
      "media"
      "models"
      "plugins"
      "recordings"
      "scripts"
      "uploads"
      "uploads/epgs"
      "uploads/m3us"
    ];

    toEnvValue = v:
      if lib.isBool v
      then lib.boolToString v
      else toString v;

    userSecretFiles = lib.filterAttrs (_: v: v != null) cfg.secretFiles;
    generateSecretKey = cfg.secretFiles.DJANGO_SECRET_KEY == null;
    generatedSecretKey = "${cfg.dataDir}/secret_key";
    secretFiles =
      userSecretFiles
      // lib.optionalAttrs generateSecretKey {DJANGO_SECRET_KEY = generatedSecretKey;};

    uwsgiAddress = "127.0.0.1:${toString cfg.internalPorts.uwsgi}";
    daphneAddress = "127.0.0.1:${toString cfg.internalPorts.daphne}";

    # recommendedProxySettings sends `Host $host` and `X-Forwarded-Host $host`,
    # which drop the port. Dispatcharr builds stream, logo and EPG URLs from
    # these headers, so playlists would point at port 80 instead of cfg.port.
    proxyHeaders = ''
      proxy_set_header Host $host:$server_port;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host:$server_port;
      proxy_set_header X-Forwarded-Port $server_port;
    '';

    environment =
      lib.optionalAttrs (cfg.secretFiles.POSTGRES_PASSWORD == null) {POSTGRES_PASSWORD = "";}
      // lib.mapAttrs (_: toEnvValue) cfg.settings
      // {
        DJANGO_SETTINGS_MODULE = "dispatcharr.settings";
        HOME = "/data";
        PYTHONPATH = pkg.pythonPath;
        DISPATCHARR_MEDIA_ROOT = "/data/media";
        DISPATCHARR_INTERNAL_TS_BASE_URL = "http://${uwsgiAddress}";
        USE_NGINX_ACCEL = "true";
      };

    servicePath = pkg.runtimeDeps ++ [config.services.postgresql.package];

    exportSecrets = names:
      lib.concatMapStrings (name: ''
        export ${name}="$(< "$CREDENTIALS_DIRECTORY/${name}")"
      '') (lib.attrNames names);

    launch = pkgs.writeShellScript "dispatcharr-launch" ''
      ${exportSecrets secretFiles}
      exec "$@"
    '';

    serviceConfig = {
      Type = "simple";
      User = cfg.user;
      Group = cfg.group;
      SupplementaryGroups = cfg.extraGroups ++ lib.optional cfg.redis.createLocally redis.group;
      WorkingDirectory = "/data";
      BindPaths = ["${cfg.dataDir}:/data"];
      LoadCredential = lib.mapAttrsToList (name: file: "${name}:${file}") secretFiles;
      StateDirectory = lib.mkIf useStateDirectory ([stateDir] ++ map (d: "${stateDir}/${d}") dataSubdirs);
      # Unlike tmpfiles, StateDirectoryMode= has no ":" keep-existing prefix.
      StateDirectoryMode = "0750";
      LimitNOFILE = 65536;
      Restart = "always";
      RestartSec = "5s";
    };

    mkService = description: execStart: extraServiceConfig: {
      inherit description environment;
      path = servicePath;
      wantedBy = ["multi-user.target"];
      after = ["dispatcharr-setup.service"];
      requires = ["dispatcharr-setup.service"];
      serviceConfig =
        serviceConfig
        // {ExecStart = "${launch} ${execStart}";}
        // extraServiceConfig;
    };

    celery = "${lib.getExe' python.pkgs.celery "celery"} --quiet -A dispatcharr";

    uwsgiIni = pkgs.writeText "dispatcharr-uwsgi.ini" ''
      [uwsgi]
      plugins = python3,gevent
      chdir = ${app}
      module = dispatcharr.wsgi:application
      http-socket = ${uwsgiAddress}
      workers = ${toString cfg.workers}
      master = true
      lazy-apps = true
      need-app = true
      die-on-term = true
      vacuum = true
      thunder-lock = true
      gevent = 400
      gevent-early-monkey-patch = true
      import = dispatcharr.gevent_patch
      buffer-size = 65536
      post-buffering = 4096
      socket-timeout = 600
      disable-logging = true
      log-4xx = true
      log-5xx = true
    '';

    manage = pkgs.writeShellScriptBin "dispatcharr-manage" ''
      exec ${lib.getExe' config.systemd.package "systemd-run"} --quiet --pty --wait --collect \
        --uid=${cfg.user} --gid=${cfg.group} --working-directory=/data \
        --property=BindPaths=${cfg.dataDir}:/data \
        ${lib.concatMapStringsSep " " (c: "--property=LoadCredential=${c}") serviceConfig.LoadCredential} \
        ${lib.concatStringsSep " " (lib.mapAttrsToList (n: v: "--setenv=${n}=${lib.escapeShellArg v}") environment)} \
        --setenv=PATH=${lib.makeBinPath servicePath} \
        ${launch} ${lib.getExe pkg} "$@"
    '';
  in {
    options.services.dispatcharr = {
      enable = lib.mkEnableOption "Dispatcharr, an IPTV stream and EPG manager";

      package = lib.mkPackageOption pkgs "dispatcharr" {};

      openFirewall = lib.mkEnableOption "opening the firewall for Dispatcharr's HTTP port";

      user = lib.mkOption {
        type = lib.types.str;
        default = defaultUser;
        description = ''
          User account under which Dispatcharr runs. The user is only created
          automatically when left at the default.
        '';
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = defaultGroup;
        description = ''
          Group under which Dispatcharr runs. The group is only created
          automatically when left at the default.
        '';
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["render" "video"];
        description = "Supplementary groups for the Dispatcharr services, e.g. for hardware transcoding.";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/dispatcharr";
        description = ''
          Persistent Dispatcharr state directory, holding logos, uploads,
          recordings, backups and plugins. It is mounted at {file}`/data`
          inside the services, where upstream expects it.

          Directories below {file}`/var/lib` are managed with systemd's
          `StateDirectory=`, other locations with systemd-tmpfiles.
        '';
      };

      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = "Address nginx listens on for the web UI and stream endpoints.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 9191;
        description = "Port nginx listens on for the web UI and stream endpoints.";
      };

      internalPorts = {
        uwsgi = lib.mkOption {
          type = lib.types.port;
          default = 5656;
          description = "Loopback port for the uWSGI application server.";
        };

        daphne = lib.mkOption {
          type = lib.types.port;
          default = 8001;
          description = "Loopback port for the Daphne websocket server.";
        };
      };

      workers = lib.mkOption {
        type = lib.types.ints.between 1 20;
        default = 4;
        description = "Number of uWSGI worker processes.";
      };

      celery = {
        minWorkers = lib.mkOption {
          type = lib.types.ints.positive;
          default = 1;
          description = "Minimum number of Celery worker processes.";
        };

        maxWorkers = lib.mkOption {
          type = lib.types.ints.positive;
          default = 6;
          description = "Maximum number of Celery worker processes (autoscaled).";
        };
      };

      database.createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to create a local PostgreSQL database for Dispatcharr.
          Dispatcharr connects to it over a Unix socket using peer
          authentication, so no password is required.
        '';
      };

      redis.createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to run a dedicated local Redis server for Dispatcharr,
          reached over its Unix socket. When disabled, set `REDIS_URL` (or
          `REDIS_HOST` and friends) in {option}`services.dispatcharr.settings`.
        '';
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf (
            lib.types.oneOf [
              lib.types.bool
              lib.types.int
              lib.types.str
            ]
          );

          options = {
            DISPATCHARR_LOG_LEVEL = lib.mkOption {
              type = lib.types.enum ["TRACE" "DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL"];
              default = "INFO";
              description = "Dispatcharr log level.";
            };

            POSTGRES_HOST = lib.mkOption {
              type = lib.types.str;
              default = "/run/postgresql";
              description = ''
                PostgreSQL host, or the directory containing its Unix socket.
              '';
            };

            POSTGRES_PORT = lib.mkOption {
              type = lib.types.port;
              default = config.services.postgresql.settings.port;
              defaultText = lib.literalExpression "config.services.postgresql.settings.port";
              description = "PostgreSQL port.";
            };

            POSTGRES_USER = lib.mkOption {
              type = lib.types.str;
              default = cfg.user;
              defaultText = lib.literalExpression "config.services.dispatcharr.user";
              description = "PostgreSQL user.";
            };

            POSTGRES_DB = lib.mkOption {
              type = lib.types.str;
              default = cfg.settings.POSTGRES_USER;
              defaultText = lib.literalExpression "config.services.dispatcharr.settings.POSTGRES_USER";
              description = "PostgreSQL database name.";
            };
          };
        };
        default = {};
        example = {
          DISPATCHARR_ENABLE_IP_LOOKUP = false;
          DISPATCHARR_TRUSTED_PROXIES = "10.100.0.1";
        };
        description = ''
          Environment variables passed to all Dispatcharr services. Secrets
          belong in {option}`services.dispatcharr.secretFiles` instead.
        '';
      };

      secretFiles = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf lib.types.path;

          options = {
            DJANGO_SECRET_KEY = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = ''
                Path to a file containing the Django secret key, which also
                signs login tokens. When unset, one is generated on first start
                and kept in {file}`''${dataDir}/secret_key`.
              '';
            };

            POSTGRES_PASSWORD = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = ''
                Path to a file containing the PostgreSQL password. Not needed when
                {option}`services.dispatcharr.database.createLocally` is enabled.
              '';
            };
          };
        };
        default = {};
        example = lib.literalExpression ''
          {
            DJANGO_SECRET_KEY = "/run/secrets/dispatcharr-secret-key";
            TMDB_API_KEY = "/run/secrets/tmdb-api-key";
          }
        '';
        description = ''
          Files whose contents are exported as environment variables, keyed by
          variable name. They are passed to the services with systemd
          `LoadCredential=` and never copied into the Nix store.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            cfg.database.createLocally
            -> cfg.settings.POSTGRES_USER == cfg.user && cfg.settings.POSTGRES_DB == cfg.settings.POSTGRES_USER;
          message = ''
            services.dispatcharr.database.createLocally uses peer authentication, so
            settings.POSTGRES_USER and settings.POSTGRES_DB must both equal services.dispatcharr.user.
          '';
        }
        {
          assertion = !cfg.database.createLocally -> cfg.secretFiles.POSTGRES_PASSWORD != null;
          message = ''
            services.dispatcharr.secretFiles.POSTGRES_PASSWORD must be set when
            services.dispatcharr.database.createLocally is disabled.
          '';
        }
        {
          assertion = cfg.celery.minWorkers <= cfg.celery.maxWorkers;
          message = "services.dispatcharr.celery.minWorkers must not exceed services.dispatcharr.celery.maxWorkers.";
        }
      ];

      services.dispatcharr.settings = lib.mapAttrs (_: lib.mkDefault) (
        lib.optionalAttrs (config.time.timeZone != null) {
          DISPATCHARR_TIME_ZONE = config.time.timeZone;
        }
        // lib.optionalAttrs cfg.redis.createLocally {
          REDIS_URL = "unix://${redis.unixSocket}?db=0";
        }
      );

      users = {
        users = lib.mkMerge [
          (lib.mkIf (cfg.user == defaultUser) {
            ${defaultUser} = {
              description = "Dispatcharr service user";
              inherit (cfg) group;
              isSystemUser = true;
            };
          })
          # nginx serves logos and backups straight from dataDir.
          {${config.services.nginx.user}.extraGroups = [cfg.group];}
        ];
        groups = lib.mkIf (cfg.group == defaultGroup) {${defaultGroup} = {};};
      };

      systemd.tmpfiles.settings."10-dispatcharr" = lib.mkIf (!useStateDirectory) (
        lib.genAttrs ([cfg.dataDir] ++ map (d: "${cfg.dataDir}/${d}") dataSubdirs) (_: {
          d = {
            inherit (cfg) user group;
            mode = ":0750";
          };
        })
      );

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

      services.postgresql = lib.mkIf cfg.database.createLocally {
        enable = true;
        ensureDatabases = [cfg.settings.POSTGRES_DB];
        ensureUsers = [
          {
            name = cfg.settings.POSTGRES_USER;
            ensureDBOwnership = true;
          }
        ];
      };

      services.redis.servers.dispatcharr = lib.mkIf cfg.redis.createLocally {
        enable = true;
        # Matches upstream's REDIS_IDLE_TIMEOUT; blocked Celery waiters are exempt.
        settings.timeout = 300;
      };

      systemd.services = {
        dispatcharr-setup = {
          description = "Dispatcharr database migrations";
          inherit environment;
          path = servicePath;
          wantedBy = ["multi-user.target"];
          after =
            ["network-online.target"]
            ++ lib.optional cfg.database.createLocally "postgresql.target"
            ++ lib.optional cfg.redis.createLocally "redis-dispatcharr.service";
          requires =
            lib.optional cfg.database.createLocally "postgresql.target"
            ++ lib.optional cfg.redis.createLocally "redis-dispatcharr.service";
          wants = ["network-online.target"];

          script = ''
            ${lib.optionalString generateSecretKey ''
              if [ ! -s /data/secret_key ]; then
                (umask 077; ${python.interpreter} -c 'import secrets; print(secrets.token_urlsafe(64))' > /data/secret_key)
              fi
              export DJANGO_SECRET_KEY="$(< /data/secret_key)"
            ''}
            ${exportSecrets userSecretFiles}
            # Clears stale stream and lock state left in Redis by a previous run.
            ${python.interpreter} ${app}/scripts/wait_for_redis.py
            exec ${lib.getExe pkg} migrate --noinput
          '';

          serviceConfig =
            serviceConfig
            // {
              Type = "oneshot";
              RemainAfterExit = true;
              # The generated key doesn't exist yet on first start.
              LoadCredential = lib.mapAttrsToList (name: file: "${name}:${file}") userSecretFiles;
              Restart = "on-failure";
            };
        };

        dispatcharr =
          mkService "Dispatcharr web application (uWSGI)"
          "${lib.getExe' pkg.uwsgi "uwsgi"} --ini ${uwsgiIni}" {
            Type = "notify";
            NotifyAccess = "all";
          };

        dispatcharr-daphne =
          mkService "Dispatcharr websocket server (Daphne)"
          "${lib.getExe' python.pkgs.daphne "daphne"} -b 127.0.0.1 -p ${toString cfg.internalPorts.daphne} dispatcharr.asgi:application" {};

        dispatcharr-celery =
          mkService "Dispatcharr background worker (Celery)"
          "${celery} worker -Q celery -n default@%H --autoscale=${toString cfg.celery.maxWorkers},${toString cfg.celery.minWorkers}" {Nice = 5;};

        dispatcharr-celery-dvr =
          mkService "Dispatcharr DVR recording worker (Celery)"
          "${celery} worker -Q dvr -n dvr@%H --pool=threads --concurrency=20" {Nice = 5;};

        dispatcharr-celerybeat =
          mkService "Dispatcharr task scheduler (Celery beat)"
          "${celery} beat --schedule /data/cache/celerybeat-schedule" {Nice = 5;};
      };

      services.nginx = {
        enable = true;
        virtualHosts.dispatcharr = {
          listen = [
            {
              addr = cfg.listenAddress;
              inherit (cfg) port;
            }
          ];

          extraConfig = ''
            client_max_body_size 0;
            proxy_connect_timeout 75;
            proxy_send_timeout 300;
            proxy_read_timeout 300;
          '';

          locations = {
            # Stream endpoints share "/" (XC paths), so never buffer.
            "/" = {
              proxyPass = "http://${uwsgiAddress}";
              # Defaults to the global setting; must stay off (see proxyHeaders).
              recommendedProxySettings = false;
              extraConfig =
                proxyHeaders
                + ''
                  proxy_buffering off;
                '';
            };
            "/ws/" = {
              proxyPass = "http://${daphneAddress}";
              proxyWebsockets = true;
              recommendedProxySettings = false;
              extraConfig = proxyHeaders;
            };
            "/assets/".alias = "${app}/static/assets/";
            "/static/".alias = "${app}/static/";
            "/logos/".alias = "${cfg.dataDir}/logos/";
            "/protected-backups/" = {
              alias = "${cfg.dataDir}/backups/";
              extraConfig = "internal;";
            };
            # Upstream disables Django admin but keeps the /admin/<user>/<channel> XC stream form.
            "~ ^/admin(?!/[^/]+/[^/]+/?$)(?:/|$)".return = "301 /login";
          };
        };
      };

      environment.systemPackages = [manage];
    };

    meta = {
      maintainers = with lib.maintainers; [mistyttm];
    };
  };
}
