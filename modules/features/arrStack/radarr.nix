{...}: {
  flake.nixosModules.radarr = {pkgs, ...}: {
    lantian.harden.radarr = {
      enable = true;
      bindPaths = [
        "/mnt/media"
        "/mnt/homework"
        "/mnt/localExpansion"
      ];
    };
    services.radarr = {
      enable = true;
      package = pkgs.radarr;
      openFirewall = true;
      user = "radarr";
      group = "media";
      dataDir = "/var/lib/radarr";
      settings = {
        update = {
          automatically = true;
        };
      };
    };
    users.users.radarr.extraGroups = ["media"];
  };
}
