{...}: {
  flake.homeModules.eza = {...}: {
    programs.eza = {
      enable = true;
      colors = "auto";
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    home.shellAliases = {
      ls = "eza -la";
    };
  };
}
