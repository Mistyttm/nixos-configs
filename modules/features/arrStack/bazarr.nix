{...}: {
  flake.nixosModules.bazarr = {...}: {
    lantian.harden.bazarr = {
      enable = false;
      bindPaths = ["/mnt/media"];
    };
    services.bazarr = {
      enable = true;
      openFirewall = true;
      group = "bazarr";
      user = "bazarr";
    };
    users.users.bazarr.extraGroups = ["media"];
  };
}
