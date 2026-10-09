{...}: {
  flake.nixosModules.kdeconnect = {...}: {
    programs.kdeconnect = {
      enable = true;
    };
  };
}
