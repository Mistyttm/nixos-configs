{...}: {
  flake.nixosModules.firefox = {pkgs, ...}: {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-bin;
      # Defaults only, so they can still be changed in about:config
      preferencesStatus = "default";
      preferences = {
        # Unload background tabs when the system is low on memory
        "browser.tabs.unloadOnLowMemory" = true;
        # Keep fewer fully-rendered pages around for back/forward
        "browser.sessionhistory.max_total_viewers" = 2;
      };
    };
  };
}
