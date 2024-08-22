{ config, lib, pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    email = "contact@mistyttm.dev";
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
