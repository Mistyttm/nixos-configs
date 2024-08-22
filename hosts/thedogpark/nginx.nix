{ config, lib, pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  sops.secrets.porkbun = {
    sopsFile = ../../secrets/porkbun.yaml;
    owner = config.users.users.nginx.name;
    group = config.users.users.nginx.group;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@mistyttm.dev";
    certs."mistyttm.dev" = {
        group = "nginx";
        dnsProvider = "porkbun";
        credentialFiles = {
          PORKBUN_SECRET_API_KEY_FILE = config.sops.secrets."porkbun/porkbun-secret-api-key".path;
          PORKBUN_API_KEY_FILE = config.sops.secrets."porkbun/porkbun-api-key".path;
        };
    };
  };

  services.nginx.virtualHosts = let
    SSL = {
      enableAcme = true;
      forceSSL = true;
    }; in {
      "minecraft.mistyttm.dev" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:25565/";
    });
  };
}
