{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.dispatcharr;
  pkg = cfg.package;
  socketPath = "/run/dispatcharr/dispatcharr.sock";

  postgresHost = if cfg.database.createLocally then "/run/postgresql" else cfg.database.host;

  commonEnv = {
    DISPATCHARR_LOG_LEVEL = cfg.logLevel;
    REDIS_HOST = cfg.redis.host;
    REDIS_PORT = toString cfg.redis.port;
    CELERY_BROKER_URL = "redis://${cfg.redis.host}:${toString cfg.redis.port}/0";
  }
  // (
    if cfg.database.type == "postgresql" then
      {
        POSTGRES_DB = cfg.database.name;
        POSTGRES_USER = cfg.database.user;
        POSTGRES_HOST = postgresHost;
        POSTGRES_PORT = toString cfg.database.port;
      }
    else
      {
        DB_ENGINE = "sqlite";
      }
  )
  // {
    BACKUP_ROOT = "${cfg.dataDir}/backups";
    LOGOS_DIR = "${cfg.dataDir}/logos";
    UPLOADS_DIR = "${cfg.dataDir}/uploads";
    PLUGINS_DIR = "${cfg.dataDir}/plugins";
    DISPATCHARR_ALLOWED_SCRIPT_DIRS = "${cfg.dataDir}/scripts";
  }
  // cfg.environment;

  envFile = "/run/dispatcharr/env";

  commonPreStart = ''
    mkdir -p /run/dispatcharr
    KEY_FILE="${cfg.dataDir}/.django-secret-key"
    ${
      if cfg.secretKeyFile != null then
        ''
          SECRET_KEY="$(cat ${cfg.secretKeyFile})"
        ''
      else
        ''
          if [ ! -f "$KEY_FILE" ]; then
            ${pkgs.python313}/bin/python -c "import secrets; print(secrets.token_urlsafe(64))" > "$KEY_FILE"
            chmod 600 "$KEY_FILE"
          fi
          SECRET_KEY="$(cat "$KEY_FILE")"
        ''
    }
    echo "DJANGO_SECRET_KEY=$SECRET_KEY" > ${envFile}
    ${lib.optionalString (cfg.database.passwordFile != null) ''
      echo "POSTGRES_PASSWORD=$(cat ${cfg.database.passwordFile})" >> ${envFile}
    ''}
    chmod 600 ${envFile}
  '';

  wrapExecStart =
    name: cmd:
    pkgs.writeShellScript "dispatcharr-${name}-start" ''
      set -euo pipefail
      if [ -f ${envFile} ]; then
        set -a
        . ${envFile}
        set +a
      fi
      exec ${cmd}
    '';
in
{
  options.services.dispatcharr = {
    enable = lib.mkEnableOption "Dispatcharr, an IPTV stream management and dispatching service";

    package = lib.mkPackageOption pkgs "dispatcharr" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9191;
      description = "The port on which the Dispatcharr web UI listens.";
    };

    websocketPort = lib.mkOption {
      type = lib.types.port;
      default = 8001;
      description = "The port on which Daphne serves WebSocket connections.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the Dispatcharr web UI port.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/dispatcharr";
      description = "Directory for persistent Dispatcharr data.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "dispatcharr";
      description = "User account under which Dispatcharr runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "dispatcharr";
      description = "Group under which Dispatcharr runs.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "trace"
        "debug"
        "info"
        "warning"
        "error"
        "critical"
      ];
      default = "info";
      description = "Log level for Dispatcharr.";
    };

    secretKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing the Django SECRET_KEY.
        If null, a key is auto-generated on first start.
      '';
    };

    database = {
      type = lib.mkOption {
        type = lib.types.enum [
          "postgresql"
          "sqlite"
        ];
        default = "postgresql";
        description = "Database backend to use.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        description = "PostgreSQL host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5432;
        description = "PostgreSQL port.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "dispatcharr";
        description = "PostgreSQL database name.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "dispatcharr";
        description = "PostgreSQL user.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to a file containing the PostgreSQL password.";
      };

      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create the PostgreSQL database and user locally.";
      };
    };

    redis = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        description = "Redis host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 6379;
        description = "Redis port.";
      };

      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable a local Redis instance.";
      };
    };

    gunicorn = {
      workers = lib.mkOption {
        type = lib.types.int;
        default = 4;
        description = "Number of gunicorn worker processes.";
      };

      workerClass = lib.mkOption {
        type = lib.types.str;
        default = "gthread";
        description = "Gunicorn worker class.";
      };

      timeout = lib.mkOption {
        type = lib.types.int;
        default = 300;
        description = "Gunicorn worker timeout in seconds.";
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional arguments to pass to gunicorn.";
      };
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional environment variables for Dispatcharr services.";
    };

  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "Dispatcharr service user";
      home = cfg.dataDir;
      createHome = true;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
      cfg.websocketPort
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}              0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/logos        0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/recordings   0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/uploads      0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/uploads/m3us 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/uploads/epgs 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/m3us         0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/epgs         0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/plugins      0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/backups      0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/scripts      0755 ${cfg.user} ${cfg.group} -"
      "d /run/dispatcharr            0775 ${cfg.user} ${cfg.group} -"
      "d /data                       0755 ${cfg.user} ${cfg.group} -"
      "L+ /data/m3us                 - - - - ${cfg.dataDir}/m3us"
      "L+ /data/epgs                 - - - - ${cfg.dataDir}/epgs"
      "L+ /data/logos                - - - - ${cfg.dataDir}/logos"
      "L+ /data/backups              - - - - ${cfg.dataDir}/backups"
      "L+ /data/uploads              - - - - ${cfg.dataDir}/uploads"
      "L+ /data/plugins              - - - - ${cfg.dataDir}/plugins"
      "L+ /data/scripts              - - - - ${cfg.dataDir}/scripts"
    ];

    services.redis = lib.mkIf cfg.redis.createLocally {
      servers.dispatcharr = {
        enable = true;
        port = cfg.redis.port;
      };
    };

    services.postgresql = lib.mkIf (cfg.database.type == "postgresql" && cfg.database.createLocally) {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.dispatcharr-migrate = {
      description = "Dispatcharr Django migrations";
      after =
        (lib.optional (
          cfg.database.type == "postgresql" && cfg.database.createLocally
        ) "postgresql.service")
        ++ (lib.optional cfg.redis.createLocally "redis-dispatcharr.service");
      requires = lib.optional (
        cfg.database.type == "postgresql" && cfg.database.createLocally
      ) "postgresql.service";
      wantedBy = [ "multi-user.target" ];
      environment = commonEnv;
      preStart = commonPreStart;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${pkg}/share/dispatcharr";
        RuntimeDirectory = "dispatcharr";
        ExecStart = wrapExecStart "migrate" "${pkg}/bin/dispatcharr-manage migrate --noinput";
      };
    };

    systemd.services.dispatcharr = {
      description = "Dispatcharr Gunicorn (WSGI)";
      after = [
        "network.target"
        "dispatcharr-migrate.service"
      ];
      requires = [ "dispatcharr-migrate.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = commonEnv;
      preStart = commonPreStart;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${pkg}/share/dispatcharr";
        RuntimeDirectory = "dispatcharr";
        RuntimeDirectoryMode = "0775";
        UMask = "0007";
        ExecStart = wrapExecStart "gunicorn" (
          lib.concatStringsSep " " (
            [
              "${pkg}/bin/dispatcharr-gunicorn"
              "--workers=${toString cfg.gunicorn.workers}"
              "--worker-class=${cfg.gunicorn.workerClass}"
              "--timeout=${toString cfg.gunicorn.timeout}"
              "--bind=unix:${socketPath}"
            ]
            ++ cfg.gunicorn.extraArgs
          )
        );
        Restart = "always";
        KillMode = "mixed";
      };
    };

    systemd.services.dispatcharr-daphne = {
      description = "Dispatcharr Daphne (ASGI/WebSockets)";
      after = [
        "network.target"
        "dispatcharr.service"
      ];
      requires = [ "dispatcharr.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = commonEnv;
      preStart = commonPreStart;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${pkg}/share/dispatcharr";
        ExecStart = wrapExecStart "daphne" "${pkg}/bin/dispatcharr-daphne -b 0.0.0.0 -p ${toString cfg.websocketPort}";
        Restart = "always";
        KillMode = "mixed";
      };
    };

    systemd.services.dispatcharr-celery = {
      description = "Dispatcharr Celery Worker";
      after = [
        "network.target"
        "dispatcharr.service"
      ];
      requires = [ "dispatcharr.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = commonEnv;
      preStart = commonPreStart;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${pkg}/share/dispatcharr";
        ExecStart = wrapExecStart "celery" "${pkg}/bin/dispatcharr-celery -l ${cfg.logLevel}";
        Restart = "always";
        KillMode = "mixed";
      };
    };

    systemd.services.dispatcharr-celerybeat = {
      description = "Dispatcharr Celery Beat Scheduler";
      after = [
        "network.target"
        "dispatcharr.service"
      ];
      requires = [ "dispatcharr.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = commonEnv;
      preStart = commonPreStart;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${pkg}/share/dispatcharr";
        ExecStart = wrapExecStart "celerybeat" "${pkg}/bin/dispatcharr-celerybeat -l ${cfg.logLevel}";
        Restart = "always";
        KillMode = "mixed";
      };
    };

    users.users.${config.services.nginx.user}.extraGroups = [ cfg.group ];

    services.nginx = {
      enable = true;
      virtualHosts."dispatcharr-local" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = cfg.port;
          }
        ];
        locations."/" = {
          proxyPass = "http://unix:${socketPath}:/";
          proxyWebsockets = true;
        };
        locations."/static/" = {
          alias = "${pkg}/share/dispatcharr/static/";
        };
        locations."/assets/" = {
          alias = "${pkg}/share/dispatcharr/frontend/dist/assets/";
        };
        locations."/ws/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.websocketPort}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
