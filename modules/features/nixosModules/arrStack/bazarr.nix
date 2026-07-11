{...}: {
  flake.nixosModules.bazarr = {...}: {
    services.bazarr = {
      enable = true;
      openFirewall = true;
      group = "bazarr";
      user = "bazarr";
    };
    users.users.bazarr.extraGroups = ["media"];
  };
}
