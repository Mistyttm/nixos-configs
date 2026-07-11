{...}: {
  flake.homeModules.ripgrep = {...}: {
    programs.ripgrep = {
      enable = true;
    };

    home.shellAliases = {
      grep = "rg";
    };
  };
}
