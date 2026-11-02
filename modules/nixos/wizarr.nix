{...}: {
  flake.nixosModules.wizarr = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.wizarr;
    pkg = cfg.package;
  in {
    options.services.wizarr = {
      enable = lib.mkEnableOption "Wizarr, a user invitation manager for Plex, Jellyfin, Emby and Audiobookshelf";

      package = lib.mkPackageOption pkgs "wizarr" {};

      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = "Address on which the service should listen.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5690;
        description = "Port on which to serve the Wizarr service.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to open the port in the firewall.
        '';
      };

      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = ''
          Environment variables passed to the Wizarr service, e.g.
          `TRUST_PROXY_HEADERS`, `GUNICORN_THREADS`, `LOG_LEVEL`,
          `WEBAUTHN_ORIGIN` or `DISABLE_BUILTIN_AUTH`.

          See [the Wizarr documentation](https://docs.wizarr.dev) for available options.
        '';
        example = {
          TRUST_PROXY_HEADERS = "true";
          WEBAUTHN_ORIGIN = "https://wizarr.example.org";
        };
      };

      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [
          "--log-level"
          "debug"
        ];
        description = ''
          Specifies extra command line arguments to pass to wizarr (Gunicorn).
        '';
      };

      credentialsFile = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        example = "/run/secrets/wizarr-credentials.env";
        description = ''
          File containing sensitive environment variables for Wizarr, such as
          {env}`CF_ACCESS_AUD`.

          Expects the format of an `EnvironmentFile=`, as described by {manpage}`systemd.exec(5)`.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.services.wizarr = {
        description = "Wizarr, a user invitation manager for media servers";

        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        environment =
          {
            # Read by upstream's gunicorn.conf.py to build its bind address.
            HOST = cfg.listenAddress;
            PORT = toString cfg.port;
            WIZARR_DATA_DIR = "/var/lib/wizarr";
          }
          // (builtins.mapAttrs (_: val: toString val) cfg.settings);

        serviceConfig = {
          DynamicUser = true;
          User = "wizarr";
          ExecStartPre = "${pkg}/libexec/init-db";
          ExecStart = "${lib.getExe pkg} ${lib.escapeShellArgs cfg.extraOptions}";
          EnvironmentFile = lib.mkIf (cfg.credentialsFile != null) cfg.credentialsFile;
          StateDirectory = "wizarr";
          StandardOutput = "journal";
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
    };
  };
}
