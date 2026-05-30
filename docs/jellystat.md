# Jellystat {#module-services-jellystat}

Source: modules/features/nixosModules/jellystat.nix

Jellystat is a statistics application for Jellyfin. This module packages it as
`services.jellystat`, stages the application into a persistent data directory,
and builds the runtime environment from Nix options instead of a hand-written
container or shell wrapper.

## Basic Usage {#module-services-jellystat-basic-usage}

A minimal deployment enables the service and provides the two required secret
inputs:

```nix
{
  services.jellystat = {
    enable = true;
    jwtSecretFile = /run/secrets/jellystat-jwt;
    database.passwordFile = /run/secrets/jellystat-postgres;
  };
}
```

That configuration starts Jellystat on `127.0.0.1:3000`, stores persistent data
under `/var/lib/jellystat`, and keeps the application process isolated as the
dedicated service user.

## Authentication {#module-services-jellystat-authentication}

Jellystat requires a JWT secret and a PostgreSQL password. The module enforces
that requirement with assertions, so the service will not activate unless one of
the supported secret paths or environment overrides is present.

The recommended approach is to set:

```nix
{
  services.jellystat = {
    jwtSecretFile = /run/secrets/jellystat-jwt;
    database.passwordFile = /run/secrets/jellystat-postgres;
  };
}
```

The upstream application also supports `JS_USER` and `JS_PASSWORD` as a master
override for account recovery. This module exposes those through `jsUser` and
`jsPasswordFile`, or through the generic `environment` option.

## Database {#module-services-jellystat-database}

Jellystat stores its metadata in PostgreSQL. By default the module points at a
local database on `127.0.0.1:5432` with the database name `jfstat` and the user
`postgres`.

You can adjust the connection details with:

```nix
{
  services.jellystat.database = {
    host = "127.0.0.1";
    port = 5432;
    name = "jfstat";
    user = "postgres";
  };
}
```

If you want Jellystat to create a local PostgreSQL database and user, enable
`database.createLocally`. That is useful for single-host deployments where the
database lives on the same machine as the service.

The module also exposes the upstream SSL flags:

`database.sslEnabled`
: Sets `POSTGRES_SSL_ENABLED`.

`database.sslRejectUnauthorized`
: Controls `POSTGRES_SSL_REJECT_UNAUTHORIZED`.

## Networking {#module-services-jellystat-networking}

Jellystat listens on the address from `listenAddress` and port from `port`.
The default bind is `0.0.0.0:3000`, while the example below opens the service to
the network by enabling the firewall hole for the configured port:

```nix
{
  services.jellystat = {
    enable = true;
    openFirewall = true;
    port = 3000;
  };
}
```

The upstream project documents the API at `/swagger`, so if you expose the
service publicly you should also consider whether the endpoint should remain
internal-only or sit behind a reverse proxy with authentication.

## Environment Variables {#module-services-jellystat-environment-variables}

The module maps the following settings into the Jellystat process environment:

`TZ`
: From `timeZone`.

`JS_LISTEN_IP`
: From `listenAddress`.

`JS_PORT`
: From `port`.

`JS_BASE_URL`
: From `baseUrl`.

`JS_USER`
: From `jsUser` or `environment.JS_USER`.

`JS_PASSWORD`
: From `jsPasswordFile` or `environment.JS_PASSWORD`.

`JWT_SECRET`
: From `jwtSecretFile` or `environment.JWT_SECRET`.

`POSTGRES_IP`
: From `database.host`.

`POSTGRES_PORT`
: From `database.port`.

`POSTGRES_DB`
: From `database.name`.

`POSTGRES_USER`
: From `database.user`.

`POSTGRES_PASSWORD`
: From `database.passwordFile` or `environment.POSTGRES_PASSWORD`.

`POSTGRES_SSL_ENABLED`
: From `database.sslEnabled`.

`POSTGRES_SSL_REJECT_UNAUTHORIZED`
: From `database.sslRejectUnauthorized`.

`JS_GEOLITE_ACCOUNT_ID`
: From `geolite.accountId`.

`JS_GEOLITE_LICENSE_KEY`
: From `geolite.licenseKeyFile`.

Any extra entries added through `environment` are passed through verbatim.
Values prefixed with `FILE__` are expanded from files at runtime, which matches
the Docker secrets convention used upstream.

## Data Directory {#module-services-jellystat-data-directory}

Jellystat runs from a persistent directory instead of the Nix store. On service
start the package contents are copied into `dataDir` and the backend is started
from there.

The default layout is:

```text
/var/lib/jellystat
├── app
│   └── backend
└── ...
```

If you move `dataDir`, make sure the chosen location has enough space for the
application files and any runtime state Jellystat may write.

## Options {#module-services-jellystat-options}

`enable`
: Enables the Jellystat service.

`package`
: Jellystat package to run.

`openFirewall`
: Opens the configured HTTP port.

`port`
: HTTP port for the Jellystat service.

`dataDir`
: Persistent data directory.

`user`
: Service user.

`group`
: Service group.

`listenAddress`
: Value for `JS_LISTEN_IP`.

`baseUrl`
: Value for `JS_BASE_URL`.

`timeZone`
: Value for `TZ`.

`jsUser`
: Optional `JS_USER` override.

`jsPasswordFile`
: File path for `JS_PASSWORD`.

`jwtSecretFile`
: File path for `JWT_SECRET`.

`geolite.accountId`
: Optional `JS_GEOLITE_ACCOUNT_ID` value.

`geolite.licenseKeyFile`
: File path for `JS_GEOLITE_LICENSE_KEY`.

`database.host`
: PostgreSQL host.

`database.port`
: PostgreSQL port.

`database.name`
: PostgreSQL database name.

`database.user`
: PostgreSQL user.

`database.passwordFile`
: File path for `POSTGRES_PASSWORD`.

`database.sslEnabled`
: Enables `POSTGRES_SSL_ENABLED`.

`database.sslRejectUnauthorized`
: Controls `POSTGRES_SSL_REJECT_UNAUTHORIZED`.

`database.createLocally`
: Creates a local PostgreSQL database and user.

`environment`
: Extra environment variables for Jellystat.

## Notes {#module-services-jellystat-notes}

The service asserts that both the JWT secret and the PostgreSQL password are
provided through one of the supported mechanisms before activation. The module
also installs Jellystat as a normal system service, creates the service account
and group, and keeps the backend process tied to the persistent data directory.

For the upstream project, see the Jellystat repository and its `/swagger` API
endpoint. The application README also documents the available environment
variables and the `FILE__*` secret convention used here.
