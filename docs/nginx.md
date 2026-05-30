# nginx {#module-doggate-nginx}

Source: modules/features/nixosModules/system-essentials/networking/nginx.nix

This module provides a host-profile driven nginx configuration under
`doggate.nginx`. The selected profile defines firewall ports, virtual hosts,
and any ACME or secret handling needed for the host.

## Usage {#module-doggate-nginx-usage}

Enable the module on a host and let the hostname select the profile:

```nix
{
  doggate.nginx.enable = true;
}
```

## Options {#module-doggate-nginx-options}

`enable`
: Enables the unified nginx configuration.

## Profiles {#module-doggate-nginx-profiles}

The module currently defines profiles for `thekennel` and `thedogpark`.

`thekennel`
: Exposes local-only reverse proxies for Jellyfin and Homepage. It opens ports
  `8082`, `8097`, and `8098` and binds the internal vhosts to the LAN and
  WireGuard addresses used on that host.

`thedogpark`
: Exposes the public nginx edge for the main site, Matrix, and media services.
  It opens ports `80`, `443`, and `8448`, configures ACME via Porkbun, and sets
  up the public virtual hosts.

## Notes {#module-doggate-nginx-notes}

When a profile provides ACME configuration, the module also wires in the needed
sops secrets and maps them to the nginx user. The module then passes the profile
virtual hosts straight through to `services.nginx.virtualHosts`.
