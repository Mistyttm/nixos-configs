# Wizarr {#module-services-wizarr}

Source: modules/nixos/wizarr.nix

[Wizarr](https://github.com/Wizarrrr/wizarr) is a user invitation and management tool for Plex, Jellyfin, Emby and Audiobookshelf.

## Quickstart {#module-services-wizarr-quickstart}

```nix
{
  services.wizarr = {
    enable = true;
    openFirewall = true;
  };
}
```

Open `http://<host>:5690` and follow the setup wizard to create the administrator account.

## Configuration {#module-services-wizarr-configuration}

`services.wizarr.settings` maps directly onto Wizarr's environment variables.
`HOST` and `PORT` are defined with types and defaults. Any other variable can be added as a string, integer or boolean:

```nix
{
  services.wizarr.settings = {
    TRUST_PROXY_HEADERS = true;
    WEBAUTHN_ORIGIN = "https://wizarr.example.org";
    GUNICORN_THREADS = 8;
  };
}
```

## Secrets {#module-services-wizarr-secrets}

`services.wizarr.secretFiles` maps environment variable names to files.
The module passes each file to the service with systemd `LoadCredential=` and exports its contents at startup, so secrets never enter the Nix store.

```nix
{
  services.wizarr.secretFiles.CF_ACCESS_AUD = "/run/secrets/wizarr-cf-access-aud";
}
```

## Directories {#module-services-wizarr-paths}

By default, Wizarr stores its SQLite database and sessions in `/var/lib/wizarr`, set as `WIZARR_DATA_DIR`.
Change the location with `services.wizarr.dataDir`.
The module creates the directory automatically: through `StateDirectory=` below `/var/lib`, and through systemd-tmpfiles anywhere else.

Database migrations run automatically before each start.

## Troubleshooting {#module-services-wizarr-troubleshooting}

```ShellSession
systemctl status wizarr.service
journalctl -u wizarr.service
```
