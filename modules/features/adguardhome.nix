{self, ...}: {
  flake.nixosModules.adguardhome = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.doggate.adguardhome;
    hostName = config.networking.hostName;
    useAcme = cfg.domain != null;
    selfSignedDir = "/var/lib/adguardhome-tls";
    acmeDir = config.security.acme.certs.${cfg.domain}.directory;
  in {
    options.doggate.adguardhome = {
      adminUser = lib.mkOption {
        type = lib.types.str;
        default = "misty";
        description = "Username for the AdGuard Home web interface.";
      };

      adminPasswordHash = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "$2y$10$...";
        description = ''
          bcrypt hash for the web interface login. While null, the web
          interface listens on 127.0.0.1 only (reach it with
          `ssh -L 3000:localhost:3000 <host>`), so an unauthenticated UI is
          never exposed to the LAN. Generate a hash with
          `nix-shell -p apacheHttpd --run 'htpasswd -nbBC 10 "" PASSWORD | tr -d ":\n"'`.
        '';
      };

      queryLogRetention = lib.mkOption {
        type = lib.types.str;
        default = "24h";
        description = ''
          How long AdGuard Home keeps the query log on local disk. Keep this
          short on small SD cards; ship the log elsewhere with
          `doggate.logShipping` for long-term history.
        '';
      };

      domain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "dns.example.com";
        description = ''
          Hostname to get a Let's Encrypt certificate for (Porkbun DNS-01).
          Enables DNS-over-HTTPS (and the web UI) on 443 and gives DoT a
          trusted certificate. The name must resolve to this host on the LAN
          (e.g. an AdGuard DNS rewrite). While null, DoT uses a self-signed
          certificate and DoH is off.
        '';
      };
    };

    config = {
      services.adguardhome = {
        enable = true;
        # With mutableSettings the declared settings below are merged over the
        # on-disk config at every start, so UI changes to other keys persist.
        mutableSettings = true;

        openFirewall = true;

        settings = {
          http = {
            address = "0.0.0.0:3000";
          };
          dns = {
            bind_hosts = ["0.0.0.0"];
            port = 53;
            upstream_dns = [
              "https://dns.cloudflare.com/dns-query"
              "https://dns.quad9.net/dns-query"
            ];
            bootstrap_dns = ["1.1.1.1" "9.9.9.9"];
            # Pass RRSIGs through; without this, validating clients (resolved) see every signed answer as Bogus.
            enable_dnssec = true;
            protection_enabled = true;
          };

          # DoT always; DoH only with a trusted cert (nothing uses DoH with a self-signed one). DoQ/DNSCrypt off.
          tls =
            {
              enabled = true;
              port_https =
                if useAcme
                then 443
                else 0;
              port_dns_over_tls = 853;
              port_dns_over_quic = 0;
              port_dnscrypt = 0;
              certificate_path =
                if useAcme
                then "${acmeDir}/fullchain.pem"
                else "${selfSignedDir}/cert.pem";
              private_key_path =
                if useAcme
                then "${acmeDir}/key.pem"
                else "${selfSignedDir}/key.pem";
            }
            // lib.optionalAttrs useAcme {server_name = cfg.domain;};

          filtering = {
            filtering_enabled = true;
            filters_update_interval = 24;
          };

          filters = [
            {
              enabled = true;
              id = 1;
              name = "AdGuard DNS filter";
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            }
          ];

          # Query log: small local window, history lives off-box (see
          # doggate.logShipping). size_memory is the in-RAM list the UI shows.
          querylog = {
            enabled = true;
            file_enabled = true;
            interval = cfg.queryLogRetention;
            size_memory = 1000;
          };

          statistics = {
            enabled = true;
            interval = "24h";
          };

          users = [
            {
              name = cfg.adminUser;
              password = cfg.adminPasswordHash;
            }
          ];
        };
      };

      # DNS for LAN clients.
      networking.firewall.allowedTCPPorts = [53 853] ++ lib.optional useAcme 443;
      networking.firewall.allowedUDPPorts = [53];

      # Generated once on the host so the private key never enters the store.
      systemd.services.adguardhome-tls-cert = lib.mkIf (!useAcme) {
        description = "Self-signed certificate for AdGuard Home DNS-over-TLS";
        before = ["adguardhome.service"];
        requiredBy = ["adguardhome.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "adguardhome";
          Group = "adguardhome";
          StateDirectory = "adguardhome-tls";
          StateDirectoryMode = "0750";
          UMask = "0077";
        };
        script = ''
          cd "$STATE_DIRECTORY"
          [ -s cert.pem ] && [ -s key.pem ] && exit 0
          ${lib.getExe pkgs.openssl} req -x509 -nodes -days 3650 \
            -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
            -subj "/CN=${hostName}" \
            -addext "subjectAltName=DNS:${hostName},DNS:${hostName}.lan" \
            -keyout key.pem -out cert.pem
        '';
      };

      sops.secrets = lib.mkIf useAcme {
        "porkbun-api-key".sopsFile = self.secrets.porkbun;
        "porkbun-secret-api-key".sopsFile = self.secrets.porkbun;
      };

      security.acme = lib.mkIf useAcme {
        acceptTerms = true;
        defaults.email = lib.mkDefault "contact@mistyttm.dev";
        certs.${cfg.domain} = {
          dnsProvider = "porkbun";
          group = "adguardhome";
          reloadServices = ["adguardhome.service"];
          credentialFiles = {
            PORKBUN_API_KEY_FILE = config.sops.secrets."porkbun-api-key".path;
            PORKBUN_SECRET_API_KEY_FILE = config.sops.secrets."porkbun-secret-api-key".path;
          };
        };
      };

      # Run as a static user (the nixpkgs unit uses DynamicUser) so the log
      # shipper can be granted read access to the query log via a group.
      users.users.adguardhome = {
        isSystemUser = true;
        group = "adguardhome";
      };
      users.groups.adguardhome = {};

      # The bind address comes from DHCP, so wait until the network is up.
      # acme-<domain> drops a placeholder cert so AdGuard can start before the real one is issued.
      systemd.services.adguardhome.after = ["network-online.target"] ++ lib.optional useAcme "acme-${cfg.domain}.service";
      systemd.services.adguardhome.wants = ["network-online.target"] ++ lib.optional useAcme "acme-${cfg.domain}.service";

      # The host resolves through its own AdGuard, whose DoH upstreams already validate;
      # validating or DoT-probing itself again just breaks during AdGuard restarts.
      services.resolved.settings.Resolve = {
        DNSStubListener = lib.mkForce "no";
        DNSSEC = lib.mkForce "false";
        DNSOverTLS = lib.mkForce "false";
      };

      systemd.services.adguardhome.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "adguardhome";
        Group = "adguardhome";
        StateDirectoryMode = "0750";
        UMask = lib.mkForce "0027";
      };

      # Let Alloy read /var/lib/AdGuardHome/data/querylog.json when it runs.
      systemd.services.alloy = lib.mkIf config.services.alloy.enable {
        serviceConfig.SupplementaryGroups = ["adguardhome"];
      };
    };
  };
}
