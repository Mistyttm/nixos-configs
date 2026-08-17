{...}: {
  flake.nixosModules.cleanuparr = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.cleanuparr;
  in {
    options.services.cleanuparr = {
      enable = lib.mkEnableOption "Advanced download manager for the Servarr ecosystem";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.cleanuparr;
        defaultText = lib.literalExpression "pkgs.cleanuparr";
        description = "Cleanuparr package to run.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall for Cleanuparr's HTTP port.";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/Cleanuparr";
        description = "Persistent Cleanuparr state directory.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "Cleanuparr";
        description = "User account under which Cleanuparr runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "Cleanuparr";
        description = "Group under which Cleanuparr runs.";
      };

      settings = {
        port = lib.mkOption {
          type = lib.types.port;
          default = 3000;
          description = "Port Cleanuparr listens on.";
        };

        bindAddress = lib.mkOption {
          type = lib.types.str;
          default = "0.0.0.0";
          description = "Value for JS_LISTEN_IP.";
        };

        basePath = lib.mkOption {
          type = lib.types.str;
          default = null;
          description = "";
        };

        database = {
          provider = lib.mkOption {
            type = lib.types.enum [
              "sqlite"
              "postgres"
            ];
            default = "sqlite";
            description = ''
              Which database backend Cleanuparr uses. `sqlite` needs no further
              configuration; `postgres` requires `host`, `user`, `database`, and
              one of `passwordFile`/`passwordEnvironmentFile` to be set.
            '';
          };

          host = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "localhost";
            description = "Postgres host. Required when `provider` is `postgres`.";
          };

          port = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = null;
            example = 5432;
            description = "Postgres port. Optional — Npgsql's own default is used if unset.";
          };

          user = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Postgres username. Required when `provider` is `postgres`.";
          };

          database = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "cleanuparr";
            description = "Postgres database name. Required when `provider` is `postgres`.";
          };

          passwordFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path to a file containing the Postgres password.
            '';
          };

          extraParams = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "SSL Mode=Require;Trust Server Certificate=true";
            description = ''
              Raw Npgsql connection-string fragment (`Key=Value;Key2=Value2`),
              merged in verbatim by Cleanuparr's own connection-string builder.
              Not validated at the Nix level — anything accepted by
              `NpgsqlConnectionStringBuilder` is accepted here too.
            '';
          };
        };
      };
    };
    config = lib.mkIf cfg.enable {};
  };
}
