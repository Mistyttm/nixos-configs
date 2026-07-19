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
    systemd.services.shelfmark.serviceConfig = {
      SupplementaryGroups = ["media"];
      PrivateUsers = lib.mkForce false;
    };
  };
}
