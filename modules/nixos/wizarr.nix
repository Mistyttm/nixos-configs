{...}: {
  flake.nixosModules.wizarr = {
    lib,
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.wizarr;

    defaultUser = "wizarr";
    defaultGroup = "wizarr";

    # StateDirectory= only manages paths below /var/lib.
    stateDir = lib.removePrefix "/var/lib/" cfg.dataDir;
    useStateDirectory = lib.hasPrefix "/var/lib/" cfg.dataDir;

    toEnvValue = v:
      if lib.isBool v
      then lib.boolToString v
      else toString v;
  in {
    options.services.wizarr = {
      enable = lib.mkEnableOption "Wizarr, a user invitation manager for Plex, Jellyfin, Emby and Audiobookshelf";

      package = lib.mkPackageOption pkgs "wizarr" {};

      openFirewall = lib.mkEnableOption "opening the firewall for Wizarr's HTTP port";

      user = lib.mkOption {
        type = lib.types.str;
        default = defaultUser;
        description = ''
          User account under which Wizarr runs. The user is only created
          automatically when left at the default.
        '';
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = defaultGroup;
        description = ''
          Group under which Wizarr runs. The group is only created
          automatically when left at the default.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/wizarr";
        description = ''
          Persistent Wizarr state directory, holding the SQLite database and
          sessions.

          Directories below {file}`/var/lib` are managed with systemd's
          `StateDirectory=`, other locations with systemd-tmpfiles.
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
            HOST = lib.mkOption {
              type = lib.types.str;
              default = "0.0.0.0";
              description = "Address Wizarr listens on.";
            };

            PORT = lib.mkOption {
              type = lib.types.port;
              default = 5690;
              description = "Port Wizarr listens on.";
            };
          };
        };
        default = {};
        example = {
          TRUST_PROXY_HEADERS = true;
          WEBAUTHN_ORIGIN = "https://wizarr.example.org";
          GUNICORN_THREADS = 8;
        };
        description = ''
          Environment variables passed to Wizarr, e.g. `TRUST_PROXY_HEADERS`,
          `LOG_LEVEL`, `WEBAUTHN_ORIGIN` or the `GUNICORN_*` tuning variables.
          See [the Wizarr documentation](https://docs.wizarr.dev) for the
          available variables. Secrets belong in
          {option}`services.wizarr.secretFiles` instead.
        '';
      };

      secretFiles = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
        example = lib.literalExpression ''
          {
            CF_ACCESS_AUD = "/run/secrets/wizarr-cf-access-aud";
          }
        '';
        description = ''
          Files whose contents are exported as environment variables, keyed by
          variable name. They are passed to the service with systemd
          `LoadCredential=` and never copied into the Nix store.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      services.wizarr.settings = lib.mapAttrs (_: lib.mkDefault) {
        WIZARR_DATA_DIR = cfg.dataDir;
      };

      users = {
        users = lib.mkIf (cfg.user == defaultUser) {
          ${defaultUser} = {
            description = "Wizarr service user";
            inherit (cfg) group;
            isSystemUser = true;
          };
        };
        groups = lib.mkIf (cfg.group == defaultGroup) {${defaultGroup} = {};};
      };

      systemd.tmpfiles.settings."10-wizarr" = lib.mkIf (!useStateDirectory) {
        ${cfg.dataDir}.d = {
          inherit (cfg) user group;
          mode = ":0750";
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.settings.PORT];

      systemd.services.wizarr = {
        description = "Wizarr service";
        wantedBy = ["multi-user.target"];
        after = ["network-online.target"];
        wants = ["network-online.target"];

        # gunicorn keeps its control socket in $HOME, and the system user's home is /var/empty.
        environment = {HOME = cfg.dataDir;} // lib.mapAttrs (_: toEnvValue) cfg.settings;

        script = ''
          ${lib.concatMapStrings (name: ''
            export ${name}="$(< "$CREDENTIALS_DIRECTORY/${name}")"
          '') (lib.attrNames cfg.secretFiles)}
          ${cfg.package}/libexec/init-db
          exec ${lib.getExe cfg.package}
        '';

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          LoadCredential = lib.mapAttrsToList (name: file: "${name}:${file}") cfg.secretFiles;
          StateDirectory = lib.mkIf useStateDirectory stateDir;
          # Unlike tmpfiles, StateDirectoryMode= has no ":" keep-existing prefix.
          StateDirectoryMode = "0750";
          Restart = "always";
          RestartSec = "5s";
        };
      };
    };

    meta = {
      maintainers = with lib.maintainers; [mistyttm];
    };
  };
}
