{inputs, ...}: {
  flake.homeModules.direnv = {...}: {
    imports = [
      inputs.direnv-instant.homeModules.direnv-instant
    ];

    programs.direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    programs.direnv-instant = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableKittyIntegration = true;

      settings = {
        use_cache = true;

        # Wait a little longer before opening a split
        mux_delay = 8;

        # Handy if something gets stuck
        debug_log = "/tmp/direnv-instant.log";
      };
    };
  };
}
