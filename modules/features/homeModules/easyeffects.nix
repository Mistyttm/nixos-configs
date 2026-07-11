{...}: {
  flake.homeModules.easyeffects = {...}: {
    services.easyeffects = {
      enable = true;
    };
  };
}
