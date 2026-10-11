{...}: {
  flake.nixosModules.shelfmark = {
    pkgs,
    lib,
    ...
  }: {
    services.shelfmark = {
      enable = true;
      package = pkgs.shelfmark;
      openFirewall = true;
      # TODO swap this to an nginx loopback ?
      environment = {
        FLASK_HOST = "0.0.0.0";
      };
    };
    systemd.services.shelfmark = {
      unitConfig.RequiresMountsFor = ["/mnt/media"];
      serviceConfig = {
        SupplementaryGroups = ["media"];
        PrivateUsers = lib.mkForce false;
        ReadWritePaths = [
          "/mnt/media/Books"
          "/mnt/localExpansion/books"
        ];
      };
    };
  };
}
