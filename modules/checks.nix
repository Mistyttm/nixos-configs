{...}: {
  perSystem = {pkgs, ...}: {
    formatter = pkgs.nixfmt;

    pre-commit = {
      settings.hooks = {
        deadnix = {
          enable = true;
          package = pkgs.deadnix;
          settings = {
            edit = true;
          };
        };
        commitizen.enable = false; # Disabled: Python 3.14 compatibility issue
        alejandra = {
          enable = true;
          package = pkgs.alejandra;
        };
      };
    };
  };
}
