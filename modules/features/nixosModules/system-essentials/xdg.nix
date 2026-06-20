{...}: {
  flake.nixosModules.xdg = {...}: {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };
  };
}
