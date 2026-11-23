{...}: {
  flake.nixosModules.sonarr = {pkgs, ...}: {
    lantian.harden.sonarr = {
      enable = false;
      bindPaths = [
        "/mnt/media"
        "/mnt/homework"
        "/mnt/localExpansion"
      ];
    };
    services.sonarr = {
      enable = true;
      package = pkgs.sonarr;
      openFirewall = true;
      user = "sonarr";
      group = "media";
      dataDir = "/var/lib/sonarr";
      settings = {
        update = {
          automatically = true;
        };
      };
    };
    users.users.sonarr.extraGroups = ["media"];
  };
}
