{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.jellystat;

  appEnv = {
    TZ = cfg.timeZone;
    JS_LISTEN_IP = cfg.listenAddress;
    JS_PORT = toString cfg.port;
    JS_BASE_URL = cfg.baseUrl;
    POSTGRES_IP = cfg.database.host;
    POSTGRES_PORT = toString cfg.database.port;
    POSTGRES_DB = cfg.database.name;
    POSTGRES_USER = cfg.database.user;
    POSTGRES_SSL_ENABLED = if cfg.database.sslEnabled then "true" else "false";
    POSTGRES_SSL_REJECT_UNAUTHORIZED = if cfg.database.sslRejectUnauthorized then "true" else "false";
  }
  // (lib.optionalAttrs (cfg.jsUser != null) {
    JS_USER = cfg.jsUser;
  })
  // (lib.optionalAttrs (cfg.geolite.accountId != null) {
    JS_GEOLITE_ACCOUNT_ID = cfg.geolite.accountId;
  })
  // (lib.optionalAttrs (cfg.jwtSecretFile != null) {
    FILE__JWT_SECRET = toString cfg.jwtSecretFile;
  })
  // (lib.optionalAttrs (cfg.database.passwordFile != null) {
    FILE__POSTGRES_PASSWORD = toString cfg.database.passwordFile;
  })
  // (lib.optionalAttrs (cfg.jsPasswordFile != null) {
    FILE__JS_PASSWORD = toString cfg.jsPasswordFile;
  })
  // (lib.optionalAttrs (cfg.geolite.licenseKeyFile != null) {
    FILE__JS_GEOLITE_LICENSE_KEY = toString cfg.geolite.licenseKeyFile;
  })
  // cfg.environment;

  startScript = pkgs.writeShellScript "jellystat-start" ''
    set -euo pipefail

    # Keep Docker parity: expand FILE__FOO=/path/to/file into FOO=<file-content>.
    while IFS='=' read -r var_name var_value; do
      case "$var_name" in
        FILE__*)
          if [ -f "$var_value" ]; then
            new_var_name="''${var_name#FILE__}"
            export "$new_var_name=$(cat "$var_value")"
          else
            echo "Error: Secret file '$var_value' does not exist"
            exit 1
          fi
          ;;
      esac
    done < <(${pkgs.coreutils}/bin/env)

    exec ${pkgs.nodejs_22}/bin/node ${cfg.dataDir}/app/backend/server.js
  '';
in
{
  options.services.jellystat = {
    enable = lib.mkEnableOption "Jellystat statistics service for Jellyfin";

    package = lib.mkPackageOption pkgs "jellystat" { };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for Jellystat's HTTP port.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port Jellystat listens on (JS_PORT).";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/jellystat";
      description = "Persistent Jellystat state directory.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "jellystat";
      description = "User account under which Jellystat runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "jellystat";
      description = "Group under which Jellystat runs.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Value for JS_LISTEN_IP.";
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "/";
      description = "Value for JS_BASE_URL.";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Etc/UTC";
      description = "Value for TZ.";
    };

    jsUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional JS_USER master override username.";
    };

    jsPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing JS_PASSWORD.";
    };

    jwtSecretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing JWT_SECRET.";
    };

    geolite = {
      accountId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional JS_GEOLITE_ACCOUNT_ID value.";
      };

      licenseKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to a file containing JS_GEOLITE_LICENSE_KEY.";
      };
    };

    database = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "PostgreSQL host for Jellystat.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5432;
        description = "PostgreSQL port for Jellystat.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "jfstat";
        description = "PostgreSQL database name for Jellystat.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "postgres";
        description = "PostgreSQL user for Jellystat.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to a file containing POSTGRES_PASSWORD.";
      };

      sslEnabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to set POSTGRES_SSL_ENABLED=true.";
      };

      sslRejectUnauthorized = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Value for POSTGRES_SSL_REJECT_UNAUTHORIZED when SSL is enabled.";
      };

      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Create local PostgreSQL database/user for Jellystat.";
      };
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        Additional environment variables for Jellystat.
        Docker-style secrets are supported by setting FILE__* variables.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.jwtSecretFile != null || (cfg.environment ? JWT_SECRET) || (cfg.environment ? FILE__JWT_SECRET);
        message = ''
          services.jellystat requires JWT_SECRET.
          Set jwtSecretFile, environment.JWT_SECRET, or environment.FILE__JWT_SECRET.
        '';
      }
      {
        assertion =
          cfg.database.passwordFile != null
          || (cfg.environment ? POSTGRES_PASSWORD)
          || (cfg.environment ? FILE__POSTGRES_PASSWORD);
        message = ''
          services.jellystat requires POSTGRES_PASSWORD.
          Set database.passwordFile, environment.POSTGRES_PASSWORD, or environment.FILE__POSTGRES_PASSWORD.
        '';
      }
    ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      description = "Jellystat service user";
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/app 0750 ${cfg.user} ${cfg.group} -"
    ];

    system.activationScripts.jellystat-prepare = lib.stringAfter [ "users" "groups" ] ''
      set -euo pipefail

      mkdir -p ${cfg.dataDir}/app
      ${pkgs.rsync}/bin/rsync -a --delete ${cfg.package}/share/jellystat/ ${cfg.dataDir}/app/
      chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
      chmod -R u+rwX,go+rX,go-w ${cfg.dataDir}/app
    '';

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      authentication = ''
        host all all 127.0.0.1/32 trust
      '';
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
          ensureClauses.createdb = true;
        }
      ];
    };

    systemd.services.jellystat = {
      description = "Jellystat service";
      wantedBy = [ "multi-user.target" ];
      after = lib.optionals cfg.database.createLocally [ "postgresql.service" ] ++ [
        "network-online.target"
      ];
      requires = lib.optionals cfg.database.createLocally [ "postgresql.service" ];
      wants = [ "network-online.target" ];

      environment = appEnv;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${cfg.dataDir}/app";
        ExecStart = startScript;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
