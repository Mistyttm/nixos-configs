# Dispatcharr {#module-services-dispatcharr}

Source: modules/nixos/dispatcharr.nix

[Dispatcharr](https://github.com/Dispatcharr/Dispatcharr) is an IPTV stream, EPG and VOD manager with an HDHomeRun and Xtream Codes compatible proxy.

## Quickstart {#module-services-dispatcharr-quickstart}

```nix
{
  services.dispatcharr = {
    enable = true;
    openFirewall = true;
  };
}
```

This configuration creates a local PostgreSQL database named `dispatcharr` and a dedicated Redis server. Dispatcharr connects to both over Unix sockets, PostgreSQL with peer authentication, so no passwords are needed.

Open `http://<host>:9191` and create the first user, which becomes the administrator.

## Services {#module-services-dispatcharr-services}

The module mirrors upstream's container as separate systemd units:

- `dispatcharr-setup.service` runs database migrations before the others start
- `dispatcharr.service` is the uWSGI application server
- `dispatcharr-daphne.service` serves websockets
- `dispatcharr-celery.service`, `dispatcharr-celery-dvr.service` and `dispatcharr-celerybeat.service` run background tasks, DVR recordings and the scheduler

nginx listens on `services.dispatcharr.port` and routes between uWSGI, Daphne and the static files.

Run management commands, such as `createsuperuser`, with the `dispatcharr-manage` wrapper as root:

```ShellSession
sudo dispatcharr-manage createsuperuser
```

## Configuration {#module-services-dispatcharr-configuration}

`services.dispatcharr.settings` maps directly onto Dispatcharr's environment variables.
The module defines the common variables with types and defaults. Any other variable can be added as a string, integer or boolean:

```nix
{
  services.dispatcharr.settings = {
    DISPATCHARR_LOG_LEVEL = "DEBUG";
    DISPATCHARR_TRUSTED_PROXIES = "10.100.0.1";
  };
}
```

For hardware transcoding, add the relevant groups with `services.dispatcharr.extraGroups`.

## Secrets {#module-services-dispatcharr-secrets}

`services.dispatcharr.secretFiles` maps environment variable names to files.
The module passes each file to the services with systemd `LoadCredential=` and exports its contents at startup, so secrets never enter the Nix store.

When `services.dispatcharr.secretFiles.DJANGO_SECRET_KEY` is unset, a key is generated on first start and kept in the data directory.

```nix
{
  services.dispatcharr.secretFiles = {
    DJANGO_SECRET_KEY = "/run/secrets/dispatcharr-secret-key";
    TMDB_API_KEY = "/run/secrets/tmdb-api-key";
  };
}
```

## External PostgreSQL and Redis {#module-services-dispatcharr-external}

```nix
{
  services.dispatcharr = {
    enable = true;
    database.createLocally = false;
    redis.createLocally = false;

    settings = {
      POSTGRES_HOST = "db.example.com";
      REDIS_URL = "redis://redis.example.com:6379/0";
    };

    secretFiles.POSTGRES_PASSWORD = "/run/secrets/dispatcharr-db-password";
  };
}
```

`services.dispatcharr.secretFiles.POSTGRES_PASSWORD` is required when `services.dispatcharr.database.createLocally` is disabled.

## Directories {#module-services-dispatcharr-paths}

Upstream expects its state below a fixed `/data`.
The module mounts `services.dispatcharr.dataDir`, by default `/var/lib/dispatcharr`, at `/data` inside each service, so the host's own `/data` is unaffected.
The module creates the directories automatically: through `StateDirectory=` below `/var/lib`, and through systemd-tmpfiles anywhere else.

## Troubleshooting {#module-services-dispatcharr-troubleshooting}

```ShellSession
systemctl status 'dispatcharr*'
journalctl -u 'dispatcharr*'
```
