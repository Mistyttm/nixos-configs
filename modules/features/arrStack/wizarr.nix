{self, ...}: {
  flake.nixosModules.wizarr-service = {...}: {
    imports = [
      self.nixosModules.wizarr
    ];

    lantian.harden.wizarr.enable = true;

    services.wizarr = {
      enable = true;
      openFirewall = true;

      # Publicly served via thedogpark's nginx (wizarr.mistyttm.dev) over WireGuard.
      settings.TRUST_PROXY_HEADERS = "true";
    };
  };
}
