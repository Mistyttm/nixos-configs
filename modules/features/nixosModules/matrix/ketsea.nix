{...}: {
  # Ketesa (formerly Synapse Admin) — static admin UI for the Matrix homeserver.
  # https://github.com/etkecc/ketesa
  flake.nixosModules.ketesa = {pkgs, ...}: {
    services.nginx.virtualHosts."ketesa-wireguard" = {
      listen = [
        {
          addr = "10.100.0.1";
          port = 8083;
        }
      ];

      root = pkgs.ketesa.withConfig {
        # Lock the UI to our own homeserver so it can't be pointed at
        # someone else's Synapse/MAS deployment.
        # https://github.com/etkecc/ketesa/blob/main/docs/config.md
        restrictBaseUrl = ["https://mistyttm.dev"];
      };

      locations."/" = {
        tryFiles = "$uri $uri/ /index.html";
        extraConfig = ''
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
        '';
      };
    };
  };
}
