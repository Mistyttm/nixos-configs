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
    };
    systemd.services.shelfmark.serviceConfig = {
      SupplementaryGroups = ["media"];
      PrivateUsers = lib.mkForce false;
    };
  };
}
